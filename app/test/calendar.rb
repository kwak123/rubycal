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
end