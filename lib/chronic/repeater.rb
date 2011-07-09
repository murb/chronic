class Chronic::Repeater < Chronic::Tag #:nodoc:
  def self.scan(tokens, options)
    # for each token
    tokens.each_index do |i|
      if t = self.scan_for_season_names(tokens[i]) then tokens[i].tag(t); next end
      if t = self.scan_for_month_names(tokens[i]) then tokens[i].tag(t); next end
      if t = self.scan_for_day_names(tokens[i]) then tokens[i].tag(t); next end
      if t = self.scan_for_day_portions(tokens[i]) then tokens[i].tag(t); next end
      if t = self.scan_for_times(tokens[i], options) then tokens[i].tag(t); next end
      if t = self.scan_for_units(tokens[i]) then tokens[i].tag(t); next end
    end
    tokens
  end

  def self.scan_for_season_names(token)
    scanner = {/^(lente)|(voorjaar)s?$/ => :spring,
               /^zomers?$/ => :summer,
               /^(herfst)|(najaar)s?$/ => :autumn,
               /^winters?$/ => :winter}
    scanner.keys.each do |scanner_item|
      return Chronic::RepeaterSeasonName.new(scanner[scanner_item]) if scanner_item =~ token.word
    end

    return nil
  end

  def self.scan_for_month_names(token)
    scanner = {/^jan\.?(uari)?$/ => :january,
               /^feb\.?(ruari)?$/ => :february,
               /^maa\.?(rt)?$/ => :march,
               /^apr\.?(il)?$/ => :april,
               /^mei$/ => :may,
               /^jun\.?i?$/ => :june,
               /^jul\.?i?$/ => :july,
               /^aug\.?(ustus)?$/ => :august,
               /^sep\.?(t\.?|tember)?$/ => :september,
               /^o[ck]t\.?(ober)?$/ => :october, #misspelling
               /^nov\.?(ember)?$/ => :november,
               /^dec\.?(ember)?$/ => :december}
    scanner.keys.each do |scanner_item|
      return Chronic::RepeaterMonthName.new(scanner[scanner_item]) if scanner_item =~ token.word
    end
    return nil
  end

  def self.scan_for_day_names(token)
    scanner = {/^ma(a)?n(dag)?$/ => :monday,
               /^dins(dag)?$/ => :tuesday,
               /^din$/ => :tuesday,
               /^woen(s)?dag$/ => :wednesday,
               /^woe$/ => :wednesday,
               /^donderdag$/ => :thursday,
               /^don$/ => :thursday,
               /^vr(ij|y)(dag)?$/ => :friday,
               /^vr[iy]$/ => :friday,
               /^zat[ue]r(dag)?$/ => :saturday,
               /^zat$/ => :saturday,
               /^zon(dag)?$/ => :sunday}
    scanner.keys.each do |scanner_item|
      return Chronic::RepeaterDayName.new(scanner[scanner_item]) if scanner_item =~ token.word
    end
    return nil
  end

  def self.scan_for_day_portions(token)
 
    scanner = {/^ams?$/ => :am,
               /^pms?$/ => :pm,
               /^ochtends?$/ => :morning,
               /^middags?$/ => :afternoon,
               /^avonds?$/ => :evening,
               /^nachts?$/ => :night,
               /^nacht?$/ => :night,
               /^namiddag$/ => :afternoon
               
               }
    scanner.keys.each do |scanner_item|
      return Chronic::RepeaterDayPortion.new(scanner[scanner_item]) if scanner_item =~ token.word
    end
    return nil
  end

  def self.scan_for_times(token, options)
    if token.word =~ /^\d{1,2}(:?\d{2})?([\.:]?\d{2})?(:)?$/
      return Chronic::RepeaterTime.new(token.word, options)
    end
    return nil
  end

  def self.scan_for_units(token)
    scanner = {/^jaa?r(s|en)?$/ => :year,
               /^[sz]ei[sz]oen(s|en)?$/ => :season,
               /^maand(s|en)?$/ => :month,
             #   /^tweewekelijks?$/ => :fortnight, # no such thing in dutch
               /^wee?k(en)?$/ => :week,
               /^weekend(s|en)?$/ => :weekend,
               /^(week|kantoor)dag(en)?$/ => :weekday,
               /^dag(en)?$/ => :day,
               #/^u?ur(en)?$/ => :hour, # had to disable this, 'uur' is also used as o'clock in English
               /^minuu?t(en)?$/ => :minute,
               /^seconde(s|n)?$/ => :second}
    scanner.keys.each do |scanner_item|
      if scanner_item =~ token.word
        klass_name = 'Chronic::Repeater' + scanner[scanner_item].to_s.capitalize
        klass = eval(klass_name)
        return klass.new(scanner[scanner_item])
      end
    end
    return nil
  end

  def <=>(other)
    width <=> other.width
  end

  # returns the width (in seconds or months) of this repeatable.
  def width
    raise("Repeatable#width must be overridden in subclasses")
  end

  # returns the next occurance of this repeatable.
  def next(pointer)
    !@now.nil? || raise("Start point must be set before calling #next")
    [:future, :none, :past].include?(pointer) || raise("First argument 'pointer' must be one of :past or :future")
    #raise("Repeatable#next must be overridden in subclasses")
  end

  def this(pointer)
    !@now.nil? || raise("Start point must be set before calling #this")
    [:future, :past, :none].include?(pointer) || raise("First argument 'pointer' must be one of :past, :future, :none")
  end

  def to_s
    'repeater'
  end
end
