require 'minitest/autorun'
require_relative '../rubycal/event'
require_relative '../rubycal/location'

class TestEvent < MiniTest::Test

  def setup
    @event = RubyCal::Event.new({ name: 'test', start_time: Time.new(2018, 1, 2, 5, 30) })
  end

  def test_event_exists
    assert @event
  end

  def test_event_needs_name
    assert @event.name
    assert_raises { RubyCal::Event.new({ start_time: Time.new(2018, 1, 2, 5, 30) }) }
    assert_raises { RubyCal::Event.new({name: '', start_time: Time.new(2018, 1, 2, 5, 30) }) }
  end

  def test_event_needs_start_time
    assert @event.start_time
    assert_raises { RubyCal::Event.new({ name: 'hi' }) }
    assert_raises { RubyCal::Event.new({ name: 'hey', start_time: 'this is not real' }) }
  end

  def test_event_can_update_primite_vars
    test_name = 'new name'
    @event.update_event({ name: test_name})
    assert_equal(@event.name, test_name)

    test_params = { start_time: Time.new(2018, 3, 6, 11, 30) }
    @event.update_event(test_params)
    assert_equal(@event.name, test_name)
    assert_equal(@event.start_time, test_params[:start_time])
  end

  def test_event_accepts_Location
    # Better to check now regarding exclusive Location object
    assert_raises { @event.update_event({ location: 'hi' }) }
    test_location = RubyCal::Location.new({ name: 'test' })
    test_params = {
      name: 'testLoc',
      start_time: Time.new(2018, 1, 2, 5, 30),
      location: test_location }
    test_event = RubyCal::Event.new(test_params)
    assert_equal(test_event.name, test_params[:name])
    assert_equal(test_event.start_time, test_params[:start_time])
    assert_equal(test_event.location.name, test_params[:location].name)
    assert_equal(test_event.location, test_params[:location]) # Compare references
  end
    
  def test_event_can_update
    @event.update_event({ name: 'test2' })
    assert_equal(@event.name, 'test2')
    test_location = RubyCal::Location.new({ name: 'test' })
    test_params = {
      name: 'new test',
      start_time: Time.new(2018, 1, 3, 5, 30),
      end_time: Time.new(2018, 2, 3, 5, 30),
      location: test_location
    }
    @event.update_event(test_params)
    assert_equal(@event.name, test_params[:name])
    assert_equal(@event.start_time, test_params[:start_time])
    assert_equal(@event.end_time, test_params[:end_time])
    assert_equal(@event.location, test_params[:location])
  end

end