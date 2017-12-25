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

  def test_app_get_cals
    assert_equal([], @app.get_cals)
    test_name = 'test'
    test_name2 = 'test2'
    @app.add_cal(test_name)
    assert_equal([test_name], @app.get_cals)
    @app.add_cal(test_name2)
    assert_equal([test_name, test_name2], @app.get_cals)
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
    refute_equal([], @app.calendar.events_with_name(test_params[:name]))
    assert_equal(1, @app.calendar.events_with_name(test_params[:name]).length)

    @app.add_event(test_params2)
    assert_equal(2, @app.calendar.events_with_name(test_params[:name]).length)

    @app.add_event(test_params3)
    assert_equal(2, @app.calendar.events_with_name(test_params[:name]).length)
    assert_equal(1, @app.calendar.events_with_name(test_params3[:name]).length)
  end

  def test_app_events_with_name
    assert_raises { @app.get_event }
    test_name = 'test'
    test_arr = [{ name: test_name, start_time: Time.now, all_day: true }, { name: test_name, start_time: Time.now, end_time: Time.now + 60 }]
    test_expected = test_arr.map do |x|
      x.select { |k| k != :name }
    end
    @app.add_cal(test_name)
    @app.use_cal(test_name)

    test_arr.each { |param| @app.add_event(param) }
    assert_equal(test_expected, @app.get_events_with_name(test_name))
  end

  def test_app_events_for_today
    assert_raises { @app.get_events_for_today }
    test_name = 'test'
    today = Time.now
    tomorrow = today + 60 * 60 * 24
    test_arr = [{ name: test_name, start_time: today, all_day: true }, { name: test_name, start_time: tomorrow, all_day: true }]
    test_expected = { test_name.to_sym => [test_arr[0].select { |k| k != :name }] }

    @app.add_cal(test_name)
    @app.use_cal(test_name)
    test_arr.each { |param| @app.add_event(param) }

    assert_equal(test_expected, @app.get_events_for_today)
  end

  def test_app_events_for_date
    assert_raises { @app.get_events_for_date(Time.now) }
    test_name = 'test'
    test_expected_date = Time.now + 60 * 60 * 24
    test_wrong_date = test_expected_date + 60 * 60 * 48
    test_arr = [{ name: test_name, start_time: test_expected_date, all_day: true }, { name: test_name, start_time: test_wrong_date, all_day: true }]
    test_expected = { test_name.to_sym => [test_arr[0].select { |k| k != :name }] }

    @app.add_cal(test_name)
    @app.use_cal(test_name)
    test_arr.each{ |param| @app.add_event(param) }

    assert_equal(test_expected, @app.get_events_for_date(test_expected_date))
  end

  def test_app_events_for_this_week
    assert_raises { @app.get_events_for_week(Time.now) }
    test_name = 'test'
    test_expected_date = Time.now
    test_wrong_date = test_expected_date + 60 * 60 * 24 * 8
    test_arr = [{ name: test_name, start_time: test_expected_date, all_day: true }, { name: test_name, start_time: test_wrong_date, all_day: true }]
    test_expected = { test_name.to_sym => [test_arr[0].select { |k| k != :name }] }

    @app.add_cal(test_name)
    @app.use_cal(test_name)
    test_arr.each{ |param| @app.add_event(param) }

    assert_equal(test_expected, @app.get_events_for_date(test_expected_date))
  end

  def test_app_update_events
    assert_raises { @app.update_events }
    test_name = 'test'
    test_old_date = Time.now
    test_new_date = test_old_date + 60 * 60 * 24 * 8
    test_old_arr = [{ name: test_name, start_time: test_old_date, all_day: true }, { name: test_name, start_time: test_old_date, all_day: true }]
    test_new_arr = [{ start_time: test_new_date, all_day: true }, { start_time: test_new_date, all_day: true }]
    test_expected = { test_name.to_sym => test_new_arr }

    @app.add_cal(test_name)
    @app.use_cal(test_name)
    test_old_arr.each { |params| @app.add_event(params) }

    @app.update_events(test_name, { start_time: test_new_date })
    assert_equal(test_expected, @app.get_events_for_date(test_new_date))
  end

  def test_app_remove_events
    assert_raises { @app.remove_events }
    test_name = 'test'
    test_date = Time.now
    test_arr = [{ name: test_name, start_time: test_date, all_day: true }, { name: test_name, start_time: test_date, all_day: true }]
    
    @app.add_cal(test_name)
    @app.use_cal(test_name)
    test_arr.each { |params| @app.add_event(params) }

    @app.remove_events(test_name)
    assert_equal([], @app.get_events_with_name(test_name))
  end
  
end