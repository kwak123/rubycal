require 'minitest/autorun'
require_relative '../rubycal/rubycal'

class TestCalendar < Minitest::Test
  def setup
    @cal = RubyCal::Calendar.new('test')
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
    test_params = { name: 'test', start_time: Time.new(2018, 1, 2, 5, 30) }
    test_event = RubyCal::Event.new(test_params)
    assert_equal(true, @cal.add_event(test_event))

    # Results should be an array
    assert_equal([test_event], @cal.events[test_event.name])
  end

  def test_cal_events_by_name
    # Return an empty hash
    assert_equal({}, @cal.events_with_name('test'))

    # Return a hash with an array containing one event
    test_params1 = { name: 'test', start_time: Time.new(2018, 1, 2, 5, 30) }
    test_event1 = RubyCal::Event.new(test_params1)
    @cal.add_event(test_event1)
    assert_equal({ test_event1.name => [test_event1] }, @cal.events_with_name(test_event1.name))

    # Return a hash with the second event
    test_params2 = { name: 'test2', start_time: Time.new(2019, 1, 2, 5, 30) }
    test_event2 = RubyCal::Event.new(test_params2)
    @cal.add_event(test_event2)
    assert_equal({ test_event2.name => [test_event2] }, @cal.events_with_name(test_event2.name))

    # Return a hash containing two events of the same name in order
    test_params3 = { name: 'test', start_time: Time.new(2020, 2, 3, 8, 45) }
    test_event3 = RubyCal::Event.new(test_params3)
    @cal.add_event(test_event3)
    assert_equal({ test_event3.name => [test_event1, test_event3] }, @cal.events_with_name(test_event3.name))

    # Make sure we only update one array bucket
    assert_equal({ test_event2.name => [test_event2] }, @cal.events_with_name(test_event2.name))
  end
end