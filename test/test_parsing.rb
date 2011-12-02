require File.join(File.dirname(__FILE__), *%w[helper])

class TestParsing < Test::Unit::TestCase
  # Wed Aug 16 14:00:00 UTC 2006
  TIME_2006_08_16_14_00_00 = Time.local(2006, 8, 16, 14, 0, 0, 0)

  def setup
    @time_2006_08_16_14_00_00 = TIME_2006_08_16_14_00_00
  end

  def test_parse_guess
    # rm_sd

    time = parse_now("27 mei")
    assert_equal Time.local(2007, 5, 27, 12), time

    time = parse_now("28 mei", :context => :past)
    assert_equal Time.local(2006, 5, 28, 12), time

      
    time = parse_now("28 mei, 5pm", :context => :past)
    assert_equal Time.local(2006, 5, 28, 17), time

    # handlers:
    #  - day_or_time
    # - dealias_and_disambiguate_times
    time = parse_now("28 mei om 17 uur", :context => :past)
    assert_equal Time.local(2006, 5, 28, 17), time

    time = parse_now("28 mei om 5:32.19", :context => :past)
    assert_equal Time.local(2006, 5, 28, 17, 32, 19), time

    # rm_sd_on
    
    
    time = parse_now("5pm op 28 mei")
    assert_equal Time.local(2007, 5, 28, 17), time
    time = parse_now("5pm, 28 mei")
    assert_equal Time.local(2007, 5, 28, 17), time
    # 

    time = parse_now("5 uur op 28 mei", :ambiguous_time_range => :none)
    assert_equal Time.local(2007, 5, 28, 05), time

    # rm_od

    time = parse_now("27 mei")
    assert_equal Time.local(2007, 5, 27, 12), time
    #Chronic.debug = true
    time = parse_now("zondag 13 nov")
    assert_equal Time.local(2006, 11, 13, 12), time
    
    time = parse_now("op 28 mei")
    assert_equal Time.local(2007, 5, 28, 12), time
    
    time = parse_now("27ste mei")
    assert_equal Time.local(2007, 5, 27, 12), time

    time = parse_now("27ste mei", :context => :past)
    assert_equal Time.local(2006, 5, 27, 12), time

    time = parse_now("27ste mei, 17:00 uur", :context => :past)
    assert_equal Time.local(2006, 5, 27, 17), time

    time = parse_now("27ste mei om 5pm", :context => :past)
    assert_equal Time.local(2006, 5, 27, 17), time

    time = parse_now("27ste mei om 5 uur", :ambiguous_time_range => :none)
    assert_equal Time.local(2007, 5, 27, 5), time

    # rm_od_on
    
    time = parse_now("27ste mei, 5:00 pm", :context => :past)
    assert_equal Time.local(2006, 5, 27, 17), time
    
    time = parse_now("27ste mei om 17 uur", :context => :past)
    assert_equal Time.local(2006, 5, 27, 17), time
    
    time = parse_now("27ste mei om 5", :ambiguous_time_range => :none)
    assert_equal Time.local(2007, 5, 27, 5), time
    
    # rm_sy
    time = parse_now("Juni, 1979")
    assert_equal Time.local(1979, 6, 16, 0), time

    time = parse_now("dec '79")
    assert_equal Time.local(1979, 12, 16, 12), time

    # rm_sd_sy

    time = parse_now("3 jan 2010")
    assert_equal Time.local(2010, 1, 3, 12), time


    
    time = parse_now("3 jan 2010 's nachts")
    assert_equal Time.local(2010, 1, 3, 22), time

    time = parse_now("3 jan 2010 middernacht")
    assert_equal Time.local(2010, 1, 3, 23, 59), time
 
    time = parse_now("3 jan 2010 at 4", :ambiguous_time_range => :none)
    assert_equal Time.local(2010, 1, 3, 4), time
 

    time = parse_now("12 januari, '00")
    assert_equal Time.local(2000, 1, 12, 12), time

    time = parse_now("27 mei, 1979")
    assert_equal Time.local(1979, 5, 27, 12), time

    time = parse_now("27 mei 79")
    assert_equal Time.local(1979, 5, 27, 12), time

    time = parse_now("27 mei 79 4:30")
    assert_equal Time.local(1979, 5, 27, 16, 30), time

    time = parse_now("27 mei 79 at 4:30", :ambiguous_time_range => :none)
    assert_equal Time.local(1979, 5, 27, 4, 30), time

    # sd_rm_sy

    time = parse_now("3 jan 2010")
    assert_equal Time.local(2010, 1, 3, 12), time

    time = parse_now("3 jan 2010 4pm")
    assert_equal Time.local(2010, 1, 3, 16), time

    time = parse_now("27 okt 2006 19:30")
    assert_equal Time.local(2006, 10, 27, 19, 30), time

    # sm_sd_sy

    time = parse_now("5/27/1979")
    assert_equal Time.local(1979, 5, 27, 12), time

    time = parse_now("5/27/1979 4am")
    assert_equal Time.local(1979, 5, 27, 4), time

    # sd_sm_sy

    time = parse_now("27/5/1979")
    assert_equal Time.local(1979, 5, 27, 12), time

    time = parse_now("27/5/1979 @ 0700")
    assert_equal Time.local(1979, 5, 27, 7), time

    # sm_sy

    time = parse_now("05/06")
    assert_equal Time.local(2006, 5, 16, 12), time

    time = parse_now("12/06")
    assert_equal Time.local(2006, 12, 16, 12), time

    time = parse_now("13/06")
    assert_equal nil, time

    # sy_sm_sd

    time = parse_now("2000-1-1")
    assert_equal Time.local(2000, 1, 1, 12), time

    time = parse_now("2006-08-20")
    assert_equal Time.local(2006, 8, 20, 12), time

    time = parse_now("2006-08-20 7pm")
    assert_equal Time.local(2006, 8, 20, 19), time

    time = parse_now("2006-08-20 03:00")
    assert_equal Time.local(2006, 8, 20, 3), time

    time = parse_now("2006-08-20 03:30:30")
    assert_equal Time.local(2006, 8, 20, 3, 30, 30), time

    time = parse_now("2006-08-20 15:30:30")
    assert_equal Time.local(2006, 8, 20, 15, 30, 30), time

    time = parse_now("2006-08-20 15:30.30")
    assert_equal Time.local(2006, 8, 20, 15, 30, 30), time
  
    # rdn_rm_rd_rt_rtz_ry
    # LOW PRIORITY for NL-NL
    # time = parse_now("Mon Apr 02 17:00:00 PDT 2007")
    # assert_equal 1175558400, time.to_i
    # 
    # now = Time.now
    # time = parse_now(now.to_s)
    # assert_equal now.to_s, time.to_s

    # rm_sd_rt

    time = parse_now("5 jan 13:00")
    assert_equal Time.local(2007, 1, 5, 13), time

    # old dates


    time = parse_now("mei 40")
    assert_equal Time.local(40, 5, 16, 12, 0, 0), time

    time = parse_now("27 mei 40")
    assert_equal Time.local(40, 5, 27, 12, 0, 0), time

    time = parse_now("1800-08-20")
    assert_equal Time.local(1800, 8, 20, 12, 0, 0), time
    # Chronic.debug = true

  time = parse_now("8 dec 19.00")
  assert_equal Time.local(2006, 12, 8, 19, 0), time

  end

  def test_parse_guess_r
    time = parse_now("vrijdag")
    assert_equal Time.local(2006, 8, 18, 12), time

    time = parse_now("din")
    assert_equal Time.local(2006, 8, 22, 12), time

    time = parse_now("5")
    assert_equal Time.local(2006, 8, 16, 17), time

    time = Chronic.parse("5", :now => Time.local(2006, 8, 16, 3, 0, 0, 0), :ambiguous_time_range => :none)
    assert_equal Time.local(2006, 8, 16, 5), time
    
    #Chronic.debug = true
    time = parse_now("om 5 uur", :now => Time.local(2006, 8, 16, 3, 0, 0, 0))
    assert_equal Time.local(2006, 8, 16, 17), time
    

    time = parse_now("13:00")
    assert_equal Time.local(2006, 8, 16, 13), time

    time = parse_now("13:45")
    assert_equal Time.local(2006, 8, 16, 13, 45), time

    time = parse_now("november")
    assert_equal Time.local(2006, 11, 16), time
  end

  def test_parse_guess_rr

    
    time = parse_now("vrijdag 13:00")
    assert_equal Time.local(2006, 8, 18, 13), time

    time = parse_now("maandag 4:00")
    assert_equal Time.local(2006, 8, 21, 16), time

    time = parse_now("zat 4:00", :ambiguous_time_range => :none)
    assert_equal Time.local(2006, 8, 19, 4), time

    time = parse_now("zondag 4:20", :ambiguous_time_range => :none)
    assert_equal Time.local(2006, 8, 20, 4, 20), time

    time = parse_now("4 pm")
    assert_equal Time.local(2006, 8, 16, 16), time

    time = parse_now("4 am", :ambiguous_time_range => :none)
    assert_equal Time.local(2006, 8, 16, 4), time

    time = parse_now("12 pm")
    assert_equal Time.local(2006, 8, 16, 12), time

    time = parse_now("12:01 pm")
    assert_equal Time.local(2006, 8, 16, 12, 1), time

    time = parse_now("12:01 am")
    assert_equal Time.local(2006, 8, 16, 0, 1), time

    time = parse_now("12 am")
    assert_equal Time.local(2006, 8, 16), time

    time = parse_now("4:00 's ochtends")
    assert_equal Time.local(2006, 8, 16, 4), time

    time = parse_now("4 november")
    assert_equal Time.local(2006, 11, 4, 12), time


    time = parse_now("24 aug")
    assert_equal Time.local(2006, 8, 24, 12), time
  end

  def test_parse_guess_rrr
    time = parse_now("vrijdag 1 pm")
    assert_equal Time.local(2006, 8, 18, 13), time

    time = parse_now("vrijdag 11 's nachts")
    assert_equal Time.local(2006, 8, 18, 23), time

    time = parse_now("vrijdag 11 's avond")
    assert_equal Time.local(2006, 8, 18, 23), time
    
    time = parse_now("vrijdag 11 in de avond")
    assert_equal Time.local(2006, 8, 18, 23), time

    time = parse_now("zondag 6am")
    assert_equal Time.local(2006, 8, 20, 6), time

    time = parse_now("vrijdagavond om 7")
    assert_equal Time.local(2006, 8, 18, 19), time
  end

  def test_parse_guess_gr
    # year

    time = parse_now("dit jaar")
    assert_equal Time.local(2006, 10, 24, 12, 30), time

    time = parse_now("dit jaar", :context => :past)
    assert_equal Time.local(2006, 4, 24, 12, 30), time

    # month

    time = parse_now("deze maand")
    assert_equal Time.local(2006, 8, 24, 12), time

    time = parse_now("deze maand", :context => :past)
    assert_equal Time.local(2006, 8, 8, 12), time

    time = Chronic.parse("volgende maand", :now => Time.local(2006, 11, 15))
    assert_equal Time.local(2006, 12, 16, 12), time

    # month name

    time = parse_now("afgelopen november")
    assert_equal Time.local(2005, 11, 16), time

    # # fortnight no such thing in duthc
    # 
    #    time = parse_now("this fortnight")
    #    assert_equal Time.local(2006, 8, 21, 19, 30), time
    # 
    #    time = parse_now("this fortnight", :context => :past)
    #    assert_equal Time.local(2006, 8, 14, 19), time

    # week

    time = parse_now("deze week")
    assert_equal Time.local(2006, 8, 18, 7, 30), time

    time = parse_now("deze week", :context => :past)
    assert_equal Time.local(2006, 8, 14, 19), time

    # weekend

    time = parse_now("dit weekend")
    assert_equal Time.local(2006, 8, 20), time

    time = parse_now("dit weekend", :context => :past)
    assert_equal Time.local(2006, 8, 13), time

    time = parse_now("afgelopen weekend")
    assert_equal Time.local(2006, 8, 13), time

    # day

    time = parse_now("deze dag")
    assert_equal Time.local(2006, 8, 16, 19, 30), time

    time = parse_now("deze dag", :context => :past)
    assert_equal Time.local(2006, 8, 16, 7), time

    time = parse_now("vandaag")
    assert_equal Time.local(2006, 8, 16, 19, 30), time

    time = parse_now("gisteren")
    assert_equal Time.local(2006, 8, 15, 12), time

    time = parse_now("morgen")
    assert_equal Time.local(2006, 8, 17, 12), time

    # day name

    time = parse_now("deze dinsdag")
    assert_equal Time.local(2006, 8, 22, 12), time

    time = parse_now("aankomende dinsdag")
    assert_equal Time.local(2006, 8, 22, 12), time

    time = parse_now("afgelopen dinsdag")
    assert_equal Time.local(2006, 8, 15, 12), time

    time = parse_now("deze woe")
    assert_equal Time.local(2006, 8, 23, 12), time

    time = parse_now("volgende woe")
    assert_equal Time.local(2006, 8, 23, 12), time

    time = parse_now("afgelopen woe")
    assert_equal Time.local(2006, 8, 9, 12), time

    # day portion

    time = parse_now("deze ochtend")
    assert_equal Time.local(2006, 8, 16, 9), time

    time = parse_now("vanavond")
    assert_equal Time.local(2006, 8, 16, 18,30), time

    # minute

    time = parse_now("volgende minuut")
    assert_equal Time.local(2006, 8, 16, 14, 1, 30), time

    # second

    time = parse_now("deze seconde")
    assert_equal Time.local(2006, 8, 16, 14), time

    time = parse_now("deze seconde", :context => :past)
    assert_equal Time.local(2006, 8, 16, 14), time

    time = parse_now("volgende seconde")
    assert_equal Time.local(2006, 8, 16, 14, 0, 1), time

    time = parse_now("afgelopen seconde")
    assert_equal Time.local(2006, 8, 16, 13, 59, 59), time
  end

  def test_parse_guess_grr
    time = parse_now("gisteren om 4 uur")
    assert_equal Time.local(2006, 8, 15, 16), time

    time = parse_now("vandaag @ 9:00")
    assert_equal Time.local(2006, 8, 16, 9), time

    time = parse_now("vandaag om 2100")
    assert_equal Time.local(2006, 8, 16, 21), time

    time = parse_now("deze dag om 0900")
    assert_equal Time.local(2006, 8, 16, 9), time

    time = parse_now("morgen om 0900")
    assert_equal Time.local(2006, 8, 17, 9), time

    time = parse_now("gisteren om 4:00", :ambiguous_time_range => :none)
    assert_equal Time.local(2006, 8, 15, 4), time

    time = parse_now("afgelopen vrijdag om 4:00")
    assert_equal Time.local(2006, 8, 11, 16), time

    time = parse_now("aanstaande woensdag, 4:00")
    assert_equal Time.local(2006, 8, 23, 16), time

    time = parse_now("gistermiddag")
    assert_equal Time.local(2006, 8, 15, 12), time

    time = parse_now("vorige week dinsdag")
    assert_equal Time.local(2006, 8, 8, 12), time

    time = parse_now("vannavond om 7 uur")
    assert_equal Time.local(2006, 8, 16, 19), time

    time = parse_now("vanavond 7")
    assert_equal Time.local(2006, 8, 16, 19), time

    time = parse_now("7 uur, vanavond")
    assert_equal Time.local(2006, 8, 16, 19), time
  end

  def test_parse_guess_grrr
    time = parse_now("vandaag om 6:00pm")
    assert_equal Time.local(2006, 8, 16, 18), time

    time = parse_now("vandaag om 6:00am")
    assert_equal Time.local(2006, 8, 16, 6), time

    time = parse_now("deze dag 1800")
    assert_equal Time.local(2006, 8, 16, 18), time

    time = parse_now("gisteren om 4:00pm")
    assert_equal Time.local(2006, 8, 15, 16), time

    time = parse_now("morgenavond om 7 uur")
    assert_equal Time.local(2006, 8, 17, 19), time

    time = parse_now("morgenochtend om 5:30")
    assert_equal Time.local(2006, 8, 17, 5, 30), time

    time = parse_now("aanstaande maandag om 12:01 am")
    assert_equal Time.local(2006, 8, 21, 00, 1), time

    time = parse_now("aanstaande maandag om 12:01 pm")
    assert_equal Time.local(2006, 8, 21, 12, 1), time
  end

  # def test_parse_guess_rgr    
  #   time = parse_now("gisteren, in de namiddag")
  #   assert_equal Time.local(2006, 8, 15, 15), time
  # 
  #   time = parse_now("vorige week dinsdag")
  #   assert_equal Time.local(2006, 8, 8, 12), time
  # end

  # def test_parse_guess_s_r_p
  #   # past
  #   time = parse_now("3 jaar geleden")
  #   assert_equal Time.local(2003, 8, 16, 14), time
  # 
  #   time = parse_now("1 month ago")
  #   assert_equal Time.local(2006, 7, 16, 14), time
  # 
  #   time = parse_now("1 fortnight ago")
  #   assert_equal Time.local(2006, 8, 2, 14), time
  # 
  #   time = parse_now("2 fortnights ago")
  #   assert_equal Time.local(2006, 7, 19, 14), time
  # 
  #   time = parse_now("3 weeks ago")
  #   assert_equal Time.local(2006, 7, 26, 14), time
  # 
  #   time = parse_now("2 weekends ago")
  #   assert_equal Time.local(2006, 8, 5), time
  # 
  #   time = parse_now("3 days ago")
  #   assert_equal Time.local(2006, 8, 13, 14), time
  # 
  #   #time = parse_now("1 monday ago")
  #   #assert_equal Time.local(2006, 8, 14, 12), time
  # 
  #   time = parse_now("5 mornings ago")
  #   assert_equal Time.local(2006, 8, 12, 9), time
  # 
  #   time = parse_now("7 hours ago")
  #   assert_equal Time.local(2006, 8, 16, 7), time
  # 
  #   time = parse_now("3 minutes ago")
  #   assert_equal Time.local(2006, 8, 16, 13, 57), time
  # 
  #   time = parse_now("20 seconds before now")
  #   assert_equal Time.local(2006, 8, 16, 13, 59, 40), time
  # 
  # end
  def test_parse_guess_s_r_p_future
    # future
  
    time = parse_now("over 3 jaar")
    assert_equal Time.local(2009, 8, 16, 14, 0, 0), time
    
    time = parse_now("over 1 dag")
    assert_equal Time.local(2006, 8 , 17, 14, 0, 0), time
    
    time = parse_now("over 2 dagen")
    assert_equal Time.local(2006, 8 , 18, 14, 0, 0), time

    time = parse_now("overmorgen")
    assert_equal Time.local(2006, 8 , 18, 14, 0, 0), time
  
    time = parse_now("na 6 maanden")
    assert_equal Time.local(2007, 2, 16, 14), time

    time = parse_now("over 1 week")
    assert_equal Time.local(2006, 8, 23, 14, 0, 0), time
  

    time = parse_now("1 weekend na nu")
    assert_equal Time.local(2006, 8, 19), time

    time = parse_now("2 weekenden na nu")
    assert_equal Time.local(2006, 8, 26), time
  
    time = parse_now("na 1 dag")
    assert_equal Time.local(2006, 8, 17, 14), time
  
    time = parse_now("5 ochtenden te gaan")
    assert_equal Time.local(2006, 8, 21, 9), time
  
      
    time = parse_now("20 minuten te gaan")
    assert_equal Time.local(2006, 8, 16, 14, 20), time
  
    time = parse_now("over 20 secondes")
    assert_equal Time.local(2006, 8, 16, 14, 0, 20), time

  end

  # def test_parse_guess_s_r_p_future_failing
  #   time = parse_now("over een uur")
  #   assert_equal Time.local(2006, 8, 16, 15), time
  # 
  #   time = Chronic.parse("2 maanden geleden", :now => Time.parse("2007-03-07 23:30"))
  #   assert_equal Time.local(2007, 1, 7, 23, 30), time
  # end

  # def test_parse_guess_p_s_r
  #     # Chronic.debug = true
  #     #     time = parse_now("volgende 3 uur")
  #     #     assert_equal Time.local(2006, 8, 16, 17), time
  #   end
  # 
    def test_parse_guess_s_r_p_a
    
      

      time = parse_now("overmorgen, 17:00")
      assert_equal Time.local(2006, 8 , 18, 17, 0, 0), time
end
def test
      
      time = parse_now("gisteren, 3 jaar geleden")
      assert_equal Time.local(2003, 8, 17, 12), time
      
      time = parse_now("komende vrijdag drie jaar geleden")
      assert_equal Time.local(2003, 8, 18, 12), time
      
      time = parse_now("zaterdag, 3 maanden geleden om 5:00 pm")
      assert_equal Time.local(2006, 5, 19, 17), time
      
      time = parse_now("2 dagen vanaf deze seconde")
      assert_equal Time.local(2006, 8, 18, 14), time
      
      time = parse_now("7 uur voor morgen middernacht")
      assert_equal Time.local(2006, 8, 17, 17), time
  
      
    end

  def test_parse_guess_o_r_s_r
    
    time = parse_now("  3de woensdag van november")
    assert_equal Time.local(2006, 11, 15, 12), time

    time = parse_now("10de woensdag in november")
    assert_equal nil, time

    # time = parse_now("3de woensdag van 2007")
    #    assert_equal Time.local(2007, 1, 20, 12), time
  end

  def test_parse_guess_o_r_g_r
    
    time = parse_now("3de maand, volgend jaar")
    assert_equal Time.local(2007, 3, 16, 11,30), time

    time = parse_now("derde donderdag aanstaande september")
    assert_equal Time.local(2006, 9, 21, 12), time

    time = parse_now("4de dag van de vorige week")
    assert_equal Time.local(2006, 8, 9, 12), time
  end

  def test_parse_guess_nonsense
    time = parse_now("some stupid nonsense")
    assert_equal nil, time

    time = parse_now("Ham Sandwich")
    assert_equal nil, time
  end

  def test_parse_span
    span = parse_now("vrijdag", :guess => false)
    assert_equal Time.local(2006, 8, 18), span.begin
    assert_equal Time.local(2006, 8, 19), span.end

    span = parse_now("november", :guess => false)
    assert_equal Time.local(2006, 11), span.begin
    assert_equal Time.local(2006, 12), span.end

    span = Chronic.parse("weekend" , :now => @time_2006_08_16_14_00_00, :guess => false)
    assert_equal Time.local(2006, 8, 19), span.begin
    assert_equal Time.local(2006, 8, 21), span.end
  end

  def test_parse_with_endian_precedence
    date = '11/02/2007'

    expect_for_middle_endian = Time.local(2007, 11, 2, 12)
    expect_for_little_endian = Time.local(2007, 2, 11, 12)

    # default precedence should be toward middle endianness
    assert_equal expect_for_middle_endian, Chronic.parse(date)

    assert_equal expect_for_middle_endian, Chronic.parse(date, :endian_precedence => [:middle, :little])

    assert_equal expect_for_little_endian, Chronic.parse(date, :endian_precedence => [:little, :middle])
  end

  def test_parse_words
    assert_equal parse_now("33 days from now"), parse_now("thirty-three days from now")
    assert_equal parse_now("2867532 seconds from now"), parse_now("two million eight hundred and sixty seven thousand five hundred and thirty two seconds from now")
    assert_equal parse_now("may 10th"), parse_now("may tenth")
  end

  def test_parse_only_complete_pointers
    assert_equal parse_now("eat pasty buns today at 2pm"), @time_2006_08_16_14_00_00
    assert_equal parse_now("futuristically speaking today at 2pm"), @time_2006_08_16_14_00_00
    assert_equal parse_now("meeting today at 2pm"), @time_2006_08_16_14_00_00
  end

  def test_am_pm
    assert_equal Time.local(2006, 8, 16), parse_now("8/16/2006 om 12am")
    assert_equal Time.local(2006, 8, 16, 12), parse_now("8/16/2006 om 12pm")
  end

  def test_a_p
    assert_equal Time.local(2006, 8, 16, 0, 15), parse_now("8/16/2006 om 12:15a")
    assert_equal Time.local(2006, 8, 16, 18, 30), parse_now("8/16/2006 om 6:30p")
  end

  def test_argument_validation
    assert_raise(Chronic::InvalidArgumentException) do
      time = Chronic.parse("may 27", :foo => :bar)
    end

    assert_raise(Chronic::InvalidArgumentException) do
      time = Chronic.parse("may 27", :context => :bar)
    end
  end

  def test_seasons
    t = parse_now("deze lente", :guess => false)
    assert_equal Time.local(2007, 3, 20, 23), t.begin
    assert_equal Time.local(2007, 6, 20), t.end

    t = parse_now("deze winter", :guess => false)
    assert_equal Time.local(2006, 12, 22, 23), t.begin
    assert_equal Time.local(2007, 3, 19,23), t.end

    t = parse_now("vorige lente", :guess => false)
    assert_equal Time.local(2006, 3, 20, 23), t.begin
    assert_equal Time.local(2006, 6, 20), t.end

    t = parse_now("vorige winter", :guess => false)
    assert_equal Time.local(2005, 12, 22, 23), t.begin
    assert_equal Time.local(2006, 3, 19, 23), t.end

    t = parse_now("volgende lente", :guess => false)
    assert_equal Time.local(2007, 3, 20,23), t.begin
    assert_equal Time.local(2007, 6, 20), t.end
  end

  # regression

  # def test_partial
  #   assert_equal '', parse_now("2 hours")
  # end

  def test_days_in_november
    t1 = Chronic.parse('1ste donderdag in november', :now => Time.local(2007))
    assert_equal Time.local(2007, 11, 1, 12), t1

    t1 = Chronic.parse('1ste vrijdag in  november', :now => Time.local(2007))
    assert_equal Time.local(2007, 11, 2, 12), t1

    t1 = Chronic.parse('1ste zaterdag in november', :now => Time.local(2007))
    assert_equal Time.local(2007, 11, 3, 12), t1

    t1 = Chronic.parse('1ste zondag in november', :now => Time.local(2007))
    assert_equal Time.local(2007, 11, 4, 12), t1

    t1 = Chronic.parse('1ste maandag in november', :now => Time.local(2007))
    assert_equal Time.local(2007, 11, 5, 12), t1
  end

  private
  def parse_now(string, options={})
    Chronic.parse(string, {:now => TIME_2006_08_16_14_00_00 }.merge(options))
  end
end
