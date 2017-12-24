# Pseudo-metamodule for running my tests

# Recommended terminal command:
# ruby -Ilib:test test.rb -v

require 'minitest/autorun'
require_relative 'app/test/calendar'
require_relative 'app/test/location'
require_relative 'app/test/event'