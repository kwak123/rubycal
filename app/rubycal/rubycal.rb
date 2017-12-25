require_relative 'calendar'
require_relative 'event'
require_relative 'location'

module RubyCal

  # Requirements
    # None

  # Implementation
    # App will be responsible for RubyCall API
    # App will also format expose friendlier responses to get requests

  class App

    attr_accessor :calendars, :calendar

    def initialize
      @calendars = {}
    end

    public
    def add_cal(name)
      raise NameError unless @calendars[name] == nil
      @calendars[name] = Calendar.new(name)
    end

    public
    def use_cal(name)
      raise NameError unless @calendars[name]
      @calendar = @calendars[name]
    end

    public
    def add_event(params)
      raise RuntimeError, 'calendar?' if @calendar == nil
      @calendar.add_event(Event.new(params))
      "Added #{params[:name]} to #{@calendar.name}"
    end

    public
    def get(name)
      raise RuntimeError unless @calendar
      results = []
      @calendar.event_by_name(name).each do |key, events|
        temp = v.map do |event|
          event.instance_variables.select { |x| x != :name }
        end
        results << [k, temp]
      end
      results
    end

  end

end