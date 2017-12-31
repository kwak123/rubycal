if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter 'test'
    command_name 'Minitest'
  end
end

require 'minitest/autorun'
require 'active_support'
require 'active_support/core_ext'
require_relative '../rubycal/rubycal'