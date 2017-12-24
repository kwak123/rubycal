require 'minitest/autorun'
require_relative '../rubycal/rubycal'

class TestLocation < Minitest::Test
  def setup
    @location = RubyCal::Location.new({ name: 'test' })
  end

  def test_loc_needs_name
    assert_raises { RubyCal::Location.new }
  end

  def test_loc_can_update
    @location.update_location({ name: 'test2' })
    assert_equal(@location.name, 'test2')

    test_params = {
      address: '123 lex ave',
      city: 'New York',
      state: 'NY',
      zip: '10013'
    }
    @location.update_location(test_params)
    assert_equal(@location.name, 'test2')
    assert_equal(@location.address, test_params[:address])
    assert_equal(@location.city, test_params[:city])
    assert_equal(@location.state, test_params[:state])
    assert_equal(@location.zip, test_params[:zip])
  end

end