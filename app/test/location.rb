require 'minitest/autorun'
require_relative '../rubycal/rubycal'

class TestLocation < Minitest::Test
  def setup
    @location = RubyCal::Location.new({ name: 'test' })
  end

  def test_loc_exists
    assert @location
  end

  def test_loc_needs_name
    assert_raises { RubyCal::Location.new }
    assert_raises { RubyCal::Location.new({ name: '' }) }
  end

  def test_loc_optionals
    test_params = {
      name: 'test',
      address: '123 lex ave',
      city: 'New York',
      state: 'NY',
      zip: '10013'
    }
    test_location = RubyCal::Location.new(test_params)
    assert_equal(test_location.name, test_params[:name])
    assert_equal(test_location.address, test_params[:address])
    assert_equal(test_location.city, test_params[:city])
    assert_equal(test_location.state, test_params[:state])
    assert_equal(test_location.zip, test_params[:zip])
  end

end