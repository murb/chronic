require File.join(File.dirname(__FILE__), *%w[helper])

class ParseNumbersTest < Test::Unit::TestCase
  def test_complexernumber_parsing
    # pend("hasn't implemented yet")
    # strings = { 
    #   21_473 => 'eenentwintigduizend vierhonderddrieenzeventig',
    #   99_999 => 'negenennegentigduizendnegenhonderdnegenennegentig',
    #   1_250_007 => 'een miljoen, tweehonderdvijftigduizendenzeven'
    #  }
    # 
    #  strings.keys.sort.each do |key|
    #    assert_equal key, Numerizer.numerize(strings[key]).to_i
    #  end
  end
  def test_complexnumber_parsing
    strings = { 
               27 => 'zevenentwintig',
               31 => 'eenendertig',
               59 => 'negenenvijftig',
               150 => 'honderdenvijftig',
               200 => 'tweehonderd',
               500 => 'vijfhonderd',
               999 => 'negenhonderdennegenennegentig',
               1_200 => 'twaalfhonderd',
               17_000 => 'zeventienduizend',
               74_002 => 'vierenzeventigduizendentwee',
               250_000 => 'tweehonderdenvijftigduizend',
    }

    strings.keys.sort.each do |key|
      assert_equal key, Numerizer.numerize(strings[key]).to_i
    end
    
  end

  def test_straight_parsing
    strings = { 1 => 'één',
               5 => 'vijf',
               10 => 'tien',
               11 => 'elf',
               12 => 'twaalf',
               13 => 'dertien',
               14 => 'veertien',
               15 => 'vijftien',
               16 => 'zestien',
               17 => 'zeventien',
               18 => 'achttien',
               19 => 'negentien',
               20 => 'twintig',
               100 => 'honderd',
               500 => '5 honderd',
               1_000 => 'duizend',
               1_200 => 'duizend en tweehonderd',
               100_000 => '100 duizend',
               1_000_000 => 'een miljoen',
               1_000_000_000 => 'een miljard',
               1_000_000_001 => 'een miljard en een' }

    strings.keys.sort.each do |key|
      assert_equal key, Numerizer.numerize(strings[key]).to_i
    end
  end

  def test_edges
    assert_equal "27 Oct 2006 7:30am", Numerizer.numerize("27 Oct 2006 7:30am")
  end
end
