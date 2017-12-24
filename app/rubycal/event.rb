module RubyCal
  class Event
    attr_accessor :name, :start_time, :end_time, :location

    def initialize(name, start_time, end_time = false, location = false)
      @name = name
      @start_time = start_time
      @end_time = end_time
      @location = location
    end