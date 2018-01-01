require_relative 'test_helper'

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

  def test_app_add_event_with_loc
    test_name = 'test'
    test_date = Time.now
    test_loc_params = { name: test_name }
    test_params = { name: test_name, start_time: test_date, all_day: true, location: test_loc_params }
    @app.add_cal(test_name)
    @app.use_cal(test_name)
    @app.add_event(test_params)
    assert_instance_of(RubyCal::Location, @app.calendar.events_with_name(test_name)[0].location)
  end

  def test_app_get_events
    assert_raises { @app.get_events }
    test_name = 'test'
    test_start = Time.now
    test_event1 = { name: 'test1', start_time: test_start, all_day: true }
    test_event2 = { name: 'test2', start_time: test_start, all_day: true }
    test_expected = {
      test1: [test_event1.select { |k| k != :name }],
      test2: [test_event2.select { |k| k != :name }]
    }
    @app.add_cal(test_name)
    @app.use_cal(test_name)
    @app.add_event(test_event1)
    @app.add_event(test_event2)
    assert_equal(test_expected, @app.get_events)
  end

  def test_app_get_events_with_name
    assert_raises { @app.get_events_with_name }
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

  def test_app_get_events_for_today
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

  def test_app_get_events_for_date
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

  def test_app_get_events_for_this_week
    assert_raises { @app.get_events_for_week(Time.now) }
    test_name = 'test'
    test_expected_date = Time.now
    test_wrong_date = test_expected_date + 60 * 60 * 24 * 8
    test_arr = [{ name: test_name, start_time: test_expected_date, all_day: true }, { name: test_name, start_time: test_wrong_date, all_day: true }]
    test_expected = { test_name.to_sym => [test_arr[0].select { |k| k != :name }] }

    @app.add_cal(test_name)
    @app.use_cal(test_name)
    test_arr.each{ |param| @app.add_event(param) }

    assert_equal(test_expected, @app.get_events_for_this_week)
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

  def test_app_update_event_loc
    test_name = 'test'
    test_loc_name = 'Test Suite'
    test_loc_update = { address: '123 Tester Road', city: 'New York', state: 'NY', zip: '10016' }
    test_expected = { name: test_loc_name, address: '123 Tester Road', city: 'New York', state: 'NY', zip: '10016' }

    test_loc_init = { name: test_loc_name }
    test_event_params = { name: test_name, start_time: Time.now, all_day: true, location: test_loc_init }

    @app.add_cal(test_name)
    @app.use_cal(test_name)
    @app.add_event(test_event_params)
    @app.update_events(test_name, { location: test_loc_update })
    assert_equal(test_expected, @app.get_events_with_name(test_name)[0][:location])
  end

  def test_app_remove_events
    assert_raises { @app.remove_events }
    test_name = 'test'
    test_date = Time.now
    test_arr = [{ name: test_name, start_time: test_date, all_day: true }, { name: test_name, start_time: test_date, all_day: true }]

    @app.add_cal(test_name)
    @app.use_cal(test_name)
    test_arr.each { |params| @app.add_event(params) }

    temp = @app.remove_events(test_name)
    assert_equal(2, temp)
    assert_raises { @app.get_events_with_name(test_name) }
  end

  def test_app_loc_formatting
    test_name = 'test'
    test_date = Time.now
    test_loc_params = { name: test_name }
    test_params = { name: test_name, start_time: test_date, all_day: true, location: test_loc_params }
    test_expected = { test_name.to_sym => [{ start_time: test_date, all_day: true, location: test_loc_params }] }
    @app.add_cal(test_name)
    @app.use_cal(test_name)
    @app.add_event(test_params)
    assert_equal(test_expected, @app.get_events_for_date(test_date))
  end
end