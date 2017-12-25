require 'minitest/autorun'
require_relative '../rubycal/rubycal'

class TestCalendar < Minitest::Test
  def setup
    @cal = RubyCal::Calendar.new('test')
  end

  def test_cal_needs_name
    assert_raises { RubyCal::Calendar.new }
    assert_raises { RubyCal::Calendar.new('') }
  end

  def test_cal_name_exists
    assert @cal.name
    assert_equal(@cal.name, 'test')
  end

  def test_cal_events_exists
    assert @cal.events
  end

  def test_cal_add_events
    assert_equal(false, @cal.add_event({}))
    test_params = { name: 'test', start_time: Time.new(2018, 1, 2, 5, 30), all_day: true }
    test_event = RubyCal::Event.new(test_params)
    assert_equal(true, @cal.add_event(test_event))

    # Results should be an array
    assert_equal([test_event], @cal.events[test_event.name])
  end

  def test_cal_events_with_name
    # Return an empty hash
    assert_equal([], @cal.events_with_name('test'))

    # Return a hash with an array containing one event
    test_params1 = { name: 'test', start_time: Time.new(2018, 1, 2, 5, 30), all_day: true }
    test_event1 = RubyCal::Event.new(test_params1)
    @cal.add_event(test_event1)
    assert_equal([test_event1], @cal.events_with_name(test_event1.name))

    # Return a hash with the second event
    test_params2 = { name: 'test2', start_time: Time.new(2019, 1, 2, 5, 30), all_day: true }
    test_event2 = RubyCal::Event.new(test_params2)
    @cal.add_event(test_event2)
    assert_equal([test_event2], @cal.events_with_name(test_event2.name))

    # Return a hash containing two events of the same name in order
    test_params3 = { name: 'test', start_time: Time.new(2020, 2, 3, 8, 45), all_day: true }
    test_event3 = RubyCal::Event.new(test_params3)
    @cal.add_event(test_event3)
    assert_equal([test_event1, test_event3], @cal.events_with_name(test_event3.name))

    # Make sure we only update one array bucket
    assert_equal([test_event2], @cal.events_with_name(test_event2.name))
  end

  def test_cal_for_today
    test_params1 = { name: 'test', start_time: Time.now + 60 * 60 * 24, all_day: true }
    test_event1 = RubyCal::Event.new(test_params1)
    @cal.add_event(test_event1)
    # Return empty hash if nothing matches
    assert_equal({}, @cal.events_for_today)

    test_params2 = { name: 'test', start_time: Time.now, all_day: true }
    test_event2 = RubyCal::Event.new(test_params2)
    @cal.add_event(test_event2)
    # The only valid event is the event2, event1 should not exist in the returned hash
    assert_equal({ test_event2.name => [test_event2] }, @cal.events_for_today)

    test_params3 = { name: 'test3', start_time: Time.now, all_day: true }
    test_event3 = RubyCal::Event.new(test_params3)
    @cal.add_event(test_event3)
    # Fetch any result, even in different buckets
    assert_equal({ test_event2.name => [test_event2], test_event3.name => [test_event3] }, @cal.events_for_today)

    test_event4 = RubyCal::Event.new(test_params2)
    @cal.add_event(test_event4)
    # Same names should have different events
    assert_equal({ test_event2.name => [test_event2, test_event4], test_event3.name => [test_event3] }, @cal.events_for_today)
  end

  def test_cal_for_date
    test_date = Time.now + 60 * 60 * 24

    test_params1 = { name: 'test', start_time: Time.now, all_day: true }
    test_event1 = RubyCal::Event.new(test_params1)
    @cal.add_event(test_event1)
    # Return empty hash if nothing matches
    assert_equal({}, @cal.events_for_date(test_date))

    test_params2 = { name: 'test', start_time: Time.now + 60 * 60 * 24, all_day: true }
    test_event2 = RubyCal::Event.new(test_params2)
    @cal.add_event(test_event2)
    # Tomorrow == tomorrow, return 1
    assert_equal({ test_event2.name => [test_event2] }, @cal.events_for_date(test_date))

    # Fetch any result, even in different buckets
    test_params3 = { name: 'test3', start_time: Time.now + 60 * 60 * 24, all_day: true }
    test_event3 = RubyCal::Event.new(test_params3)
    @cal.add_event(test_event3)
    assert_equal({ test_event2.name => [test_event2], test_event3.name => [test_event3] }, @cal.events_for_date(test_date))

    test_event4 = RubyCal::Event.new(test_params2)
    @cal.add_event(test_event4)
    # Same names should have different events
    assert_equal({ test_event2.name => [test_event2, test_event4], test_event3.name => [test_event3] }, @cal.events_for_date(test_date))
  end

  def test_cal_for_week
    test_date = Time.now + 60 * 60 * 24 * 8 # 8 days from now

    test_params1 = { name: 'test', start_time: test_date, all_day: true }
    test_event1 = RubyCal::Event.new(test_params1)
    @cal.add_event(test_event1)
    # Return empty hash if nothing matches
    assert_equal({}, @cal.events_for_this_week)

    test_params2 = { name: 'test2', start_time: Time.now, all_day: true }
    test_event2 = RubyCal::Event.new(test_params2)
    @cal.add_event(test_event2)
    # We got a match
    assert_equal({ test_event2.name => [test_event2] }, @cal.events_for_this_week)

    test_params3 = { name: 'test3', start_time: Time.now + 60 * 60 * 24 * 6, all_day: true }
    test_event3 = RubyCal::Event.new(test_params3)
    @cal.add_event(test_event3)
    # Different names, different events
    assert_equal({ test_event2.name => [test_event2], test_event3.name => [test_event3] }, @cal.events_for_this_week)

    test_event4 = RubyCal::Event.new(test_params2)
    @cal.add_event(test_event4)
    # Same names should have different events
    assert_equal({ test_event2.name => [test_event2, test_event4], test_event3.name => [test_event3] }, @cal.events_for_this_week)
  end

  def test_cal_update
    test_date = Time.now # 8 days from now
    test_update = test_date + 60 * 60
    test_update_params = { start_time: test_update }

    test_params1 = { name: 'test', start_time: test_date, all_day: true }
    test_event1 = RubyCal::Event.new(test_params1)
    @cal.add_event(test_event1)
    @cal.update_events(test_event1.name, test_update_params)
    assert_equal(test_update, @cal.events_with_name(test_event1.name)[0].start_time)
  end

  def test_cal_remove
    test_params1 = { name: 'test', start_time: Time.now, all_day: true }
    test_event1 = RubyCal::Event.new(test_params1)
    @cal.add_event(test_event1)
    # Add first
    assert_equal([test_event1], @cal.events_with_name(test_event1.name))
    
    @cal.remove_events(test_event1.name)
    assert_equal([], @cal.events_with_name(test_event1.name))
  end

end