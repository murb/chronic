require 'strscan'

class Numerizer

  DIRECT_NUMS = [
                  ['elf', '11'],
                  ['twaalf', '12'],
                  ['dertien', '13'],
                  ['veertien', '14'],
                  ['vijftien', '15'],
                  ['zestien', '16'],
                  ['zeventien', '17'],
                  ['achtt?ien', '18'],
                  ['negentien', '19'],
                  ['nul', '0'],
                  ['een', '1'],
                  ['één', '1'],
                  ['twee', '2'],
                  ['drie', '3'],
                  ['vier', '4'],  # The weird regex is so that it matches four but not fourty
                  ['vijf(\W|$)', '5\1'],
                  ['zes(\W|$)', '6\1'],
                  ['zeven(\W|$)', '7\1'],
                  ['\bacht', '8'],
                  ['negen(\W|$)', '9\1'],
                  ['tien', '10'],
                  ['\been[\b^$]', '1'] # doesn't make sense for an 'a' at the end to be a 1
                ]

  TEN_PREFIXES = [ ['twintig', 20],
                    ['dertig', 30],
                    ['veertig', 40],
                    ['vijftig', 50],
                    ['zestig', 60],
                    ['zeventig', 70],
                    ['tachtig', 80],
                    ['negentig', 90]
                  ]

  BIG_PREFIXES = [ ['honderd', 100],
                    ['duizend', 1000],
                    ['miljoen', 1_000_000],
                    ['miljard', 1_000_000_000],
                    ['biljoen', 1_000_000_000_000],
                  ]

  def self.numerize(string)
    string = string.dup

    # preprocess
    string.gsub!(/ +|([^\d])-([^\d])/, '\1 \2') # will mutilate hyphenated-words but shouldn't matter for date extraction
    string.gsub!(/een half/, 'haAlf') # take the 'a' out so it doesn't turn into a 1, save the half for the end
    string.gsub!(/(n|r|f|s|acht|d)en/,'\1 en ')

    BIG_PREFIXES.each do |bp|
      string.gsub!(/(#{bp[0]})/, ' \1')
    end
    # easy/direct replacements

    DIRECT_NUMS.each do |dn|
      string.gsub!(/#{dn[0]}/i, '<num>' + dn[1])
    end

    # ten, twenty, etc.

    TEN_PREFIXES.each do |tp|
      string.gsub!(/(?:#{tp[0]}) *<num>(\d(?=[^\d]|$))*/i) { '<num>' + (tp[1] + $1.to_i).to_s }
    end

    TEN_PREFIXES.each do |tp|
      string.gsub!(/#{tp[0]}/i) { '<num>' + tp[1].to_s }
    end

    # hundreds, thousands, millions, etc.

    BIG_PREFIXES.each do |bp|
      string.gsub!(/(?:<num>)?(\d*) *#{bp[0]}/i) do
        multiplier = $1
        multiplier = 1 if multiplier.empty?
        '<num>' + (bp[1] * multiplier.to_i).to_s
      end
      andition(string)
    end

    # fractional addition
    # I'm not combining this with the previous block as using float addition complicates the strings
    # (with extraneous .0's and such )
    string.gsub!(/(\d+)(?: | en |-)*haAlf/i) { ($1.to_f + 0.5).to_s }

    string.gsub(/<num>/, '')
  end

  private

  def self.andition(string)
    sc = StringScanner.new(string)
    while(sc.scan_until(/<num>(\d+)( | en )<num>(\d+)(?=[^\w]|$)/i))
      if sc[2] =~ /en/ || sc[1].size > sc[3].size
        string[(sc.pos - sc.matched_size)..(sc.pos-1)] = '<num>' + (sc[1].to_i + sc[3].to_i).to_s
        sc.reset
      end
    end
  end

end
