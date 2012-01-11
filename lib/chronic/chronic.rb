module Chronic
  class << self

    # Parses a string containing a natural language date or time. If the parser
    # can find a date or time, either a Time or Chronic::Span will be returned
    # (depending on the value of <tt>:guess</tt>). If no date or time can be found,
    # +nil+ will be returned.
    #
    # Options are:
    #
    # [<tt>:context</tt>]
    #     <tt>:past</tt> or <tt>:future</tt> (defaults to <tt>:future</tt>)
    #
    #     If your string represents a birthday, you can set <tt>:context</tt> to <tt>:past</tt>
    #     and if an ambiguous string is given, it will assume it is in the
    #     past. Specify <tt>:future</tt> or omit to set a future context.
    #
    # [<tt>:now</tt>]
    #     Time (defaults to Time.now)
    #
    #     By setting <tt>:now</tt> to a Time, all computations will be based off
    #     of that time instead of Time.now. If set to nil, Chronic will use Time.now.
    #
    # [<tt>:guess</tt>]
    #     +true+ or +false+ (defaults to +true+)
    #
    #     By default, the parser will guess a single point in time for the
    #     given date or time. If you'd rather have the entire time span returned,
    #     set <tt>:guess</tt> to +false+ and a Chronic::Span will be returned.
    #
    # [<tt>:ambiguous_time_range</tt>]
    #     Integer or <tt>:none</tt> (defaults to <tt>6</tt> (6am-6pm))
    #
    #     If an Integer is given, ambiguous times (like 5:00) will be
    #     assumed to be within the range of that time in the AM to that time
    #     in the PM. For example, if you set it to <tt>7</tt>, then the parser will
    #     look for the time between 7am and 7pm. In the case of 5:00, it would
    #     assume that means 5:00pm. If <tt>:none</tt> is given, no assumption
    #     will be made, and the first matching instance of that time will
    #     be used.
    def parse(text, specified_options = {})
      @text = text

      # get options and set defaults if necessary
      default_options = {:context => :future,
                         :now => Chronic.time_class.now,
                         :guess => true,
                         :ambiguous_time_range => 6,
                         :endian_precedence => nil}
      options = default_options.merge specified_options

      # handle options that were set to nil
      options[:context] = :future unless options[:context]
      options[:now] = Chronic.time_class.now unless options[:context]
      options[:ambiguous_time_range] = 6 unless options[:ambiguous_time_range]

      # ensure the specified options are valid
      specified_options.keys.each do |key|
        default_options.keys.include?(key) || raise(InvalidArgumentException, "#{key} is not a valid option key.")
      end
      [:past, :future, :none].include?(options[:context]) || raise(InvalidArgumentException, "Invalid value ':#{options[:context]}' for :context specified. Valid values are :past and :future.")

      # store now for later =)
      @now = options[:now]

      @tokens = tokenize(text,options)
      
      # strip any non-tagged tokens
      @tokens = @tokens.select { |token| token.tagged? }

      if Chronic.debug
        puts "+---------------------------------------------------"
        puts "| " + @tokens.to_s
        puts "+---------------------------------------------------"
      end

      # do the heavy lifting
      begin
        span = self.tokens_to_span(@tokens, options)
      rescue
        raise
        return nil
      end
      
      # guess a time within a span if required
      if options[:guess]
        return self.guess(span)
      else
        return span
      end
    end
    
    def tokenize(text, options)
      # put the text into a normal format to ease scanning
      text = self.pre_normalize(text)
      # get base tokens for each word
      tokens = self.base_tokenize(text)
      
      # scan the tokens with each token scanner
      [Repeater].each do |tokenizer|
        tokens = tokenizer.scan(tokens, options)
      end

      [Grabber, Pointer, Scalar, Ordinal, Separator, TimeZone].each do |tokenizer|
        tokens = tokenizer.scan(tokens)
      end

      
      
      return tokens
    end

    # Clean up the specified input text by stripping unwanted characters,
    # converting idioms to their canonical form, converting number words
    # to numbers (three => 3), and converting ordinal words to numeric
    # ordinals (third => 3rd)
    def pre_normalize(text) #:nodoc:
      normalized_text = text.to_s.downcase
      normalized_text.gsub!(/\bnog\b/, 'over')
      normalized_text.gsub!(/\b(a.s.)\b/, 'volgende')
      normalized_text.gsub!(/\b(\d\d)\.(\d\d)/, '\1:\2')
      normalized_text.gsub!(/\b(\d\d\:\d\d)u\b/, '\1')
      normalized_text.gsub!(/\bvan de\b/,'')
      normalized_text.gsub!(/\beerste\b/,'1ste')
      normalized_text.gsub!(/\bderde\b/,'3de')
      normalized_text.gsub!(/\bovermorgen\b/, 'over 2 dagen')
      normalized_text = decompose_words(normalized_text)
      normalized_text = numericize_numbers(normalized_text)
      normalized_text.gsub!(/['"\.,]/, '')
      normalized_text = repair_words(normalized_text)
      normalized_text.gsub!(/ \-(\d{4})\b/, ' tzminus\1')
      normalized_text.gsub!(/([\/\-\,\@])/) { ' ' + $1 + ' ' }
      normalized_text.gsub!(/\bvandaag\b/, 'deze dag')
      normalized_text.gsub!(/\bmorgen\b/, 'volgende dag')
      normalized_text.gsub!(/\bgister(|en)\b/, 'afgelopen dag')
      normalized_text.gsub!(/\bochtends\b/, 'am')
      normalized_text.gsub!(/\bnamiddag\b/, '16:30')
      normalized_text.gsub!(/\bvanavond\b/, 'deze avond')
      normalized_text.gsub!(/\bvanmorgen\b/, 'deze ochtend')
      normalized_text.gsub!(/\bvanochtend\b/, 'deze ochtend')
      normalized_text.gsub!(/\bvanmiddag\b/, 'deze middag')
      normalized_text.gsub!(/\bmiddag\b/, '12:00')
      normalized_text.gsub!(/\bmidder nacht\b/, '23:59')  
      normalized_text.gsub!(/\bte gaan\b/, 'na nu')    
      #normalized_text.gsub!(/\bnu\b/, 'op dit moment')
      normalized_text.gsub!(/\b(aan(staande|komende)|volgend)\b/, 'volgende')
      normalized_text.gsub!(/\b(beerder|geleden|voor die tijd)\b/, 'verleden')
      normalized_text.gsub!(/\b(?:in|gedurende) de (morgen)\b/, '\1')
      normalized_text.gsub!(/\b(?:in de|gedurende|\'s) (middag|avond|nacht)(s?)\b/, '\1')
      normalized_text.gsub!(/\bvannacht\b/, 'deze nacht')
      normalized_text.gsub!(/\b\d+:?\d*[ap]\b/,'\0m')
      normalized_text.gsub!(/(\d)([ap]m|uur)\b/, '\1 \2')
      normalized_text.gsub!(/\b(vandaar|van)\b/, 'toekomst')
      normalized_text = numericize_ordinals(normalized_text)
      normalized_text
    end
    
    # Instead of 'saterday evening' a dutchman would write 'saterdayevening'
    def decompose_words(text) #:nodoc:
      text.gsub!(/vandaag/, 'deze dag')
      text.gsub!(/\bvan(.*)/,'deze \1')
      text.gsub!(/(morgen|avond|nacht|ochtend|middag)\b/, ' \1')
      text
    end
    
    #fixing stuff that was broken
    def repair_words(text) #:nodoc:
      text.gsub!(/gister en/, 'gisteren')
      text
    end

    # Convert number words to numbers (three => 3)
    def numericize_numbers(text) #:nodoc:
      Numerizer.numerize(text)
    end

    # Convert ordinal words to numeric ordinals (third => 3rd)
    def numericize_ordinals(text) #:nodoc:
      text
    end

    # Split the text on spaces and convert each word into
    # a Token
    def base_tokenize(text) #:nodoc:
      text.split(' ').map { |word| Token.new(word) }
    end

    # Guess a specific time within the given span
    def guess(span) #:nodoc:
      return nil if span.nil?
      if span.width > 1
        span.begin + (span.width / 2)
      else
        span.begin
      end
    end
  end

  class Token #:nodoc:
    attr_accessor :word, :tags

    def initialize(word)
      @word = word
      @tags = []
    end

    # Tag this token with the specified tag
    def tag(new_tag)
      @tags << new_tag
    end

    # Remove all tags of the given class
    def untag(tag_class)
      @tags = @tags.select { |m| !m.kind_of? tag_class }
    end

    # Return true if this token has any tags
    def tagged?
      @tags.size > 0
    end

    # Return the Tag that matches the given class
    def get_tag(tag_class)
      matches = @tags.select { |m| m.kind_of? tag_class }
      #matches.size < 2 || raise("Multiple identical tags found")
      return matches.first
    end

    # Print this Token in a pretty way
    def to_s
      @word << '(' << @tags.join(', ') << ') '
    end
  end

  # A Span represents a range of time. Since this class extends
  # Range, you can use #begin and #end to get the beginning and
  # ending times of the span (they will be of class Time)
  class Span < Range
    # Returns the width of this span in seconds
    def width
      (self.end - self.begin).to_i
    end

    # Add a number of seconds to this span, returning the
    # resulting Span
    def +(seconds)
      Span.new(self.begin + seconds, self.end + seconds)
    end

    # Subtract a number of seconds to this span, returning the
    # resulting Span
    def -(seconds)
      self + -seconds
    end

    # Prints this span in a nice fashion
    def to_s
      '(' << self.begin.to_s << '..' << self.end.to_s << ')'
    end
  end

  # Tokens are tagged with subclassed instances of this class when
  # they match specific criteria
  class Tag #:nodoc:
    attr_accessor :type

    def initialize(type)
      @type = type
    end

    def start=(s)
      @now = s
    end
  end

  # Internal exception
  class ChronicPain < Exception #:nodoc:

  end

  # This exception is raised if an invalid argument is provided to
  # any of Chronic's methods
  class InvalidArgumentException < Exception

  end
end
