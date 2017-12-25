require 'minitest/autorun'
require_relative '../rubycal/rubycal'

class TestRubyCal < MiniTest::Test
  def setup
    @app = RubyCal::App.new
  end

  def test_app_add_cal
    assert_raises { @app.add_cal }
    test_name = 'test'
    @app.add_cal(test_name)
    # add_cal should create a calendar
    assert @app.calendars[test_name]

    test_name2 = 'test2'
    @app.add_cal(test_name2)
    assert @app.calendars[test_name2]

    # cannot add two of same (would lose all cal data!)
    assert_raises { @app.add_cal(test_name) }
  end

  def test_app_use_cal
    assert_raises { @app.use_cal('i should not exist') }

    test_name = 'test'
    test_name2 = 'test2'
    @app.add_cal(test_name)
    @app.add_cal(test_name2)
    @app.use_cal(test_name2)
    assert_equal(test_name2, @app.calendar.name)
    assert_equal(2, @app.calendars.length)

    @app.use_cal(test_name)
    assert_equal(test_name, @app.calendar.name)
  end
  
  def test_app_add_event
    assert_raises { @app.add_event }
    test_name = 'test'
    test_params = { name: 'test', start_time: Time.now, all_day: true, end_time: nil, location: nil }
    test_params2 = { name: 'test', start_time: Time.now, all_day: true }
    test_params3 = { name: 'test2', start_time: Time.now, end_time: Time.now + 60 }
    @app.add_cal(test_name)
    @app.use_cal(test_name)

    @app.add_event(test_params)
    # app calendar should have something now
    refute_equal({}, @app.calendar.events_with_name(test_params[:name]))

    @app.add_event(test_params2)
    
  end
  
end