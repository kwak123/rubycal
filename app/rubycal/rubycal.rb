require 'active_support'
require 'active_support/core_ext'

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
      raise NameError if @calendars[name]
      @calendars[name] = Calendar.new(name)
    end

    public
    def use_cal(name)
      raise NameError unless @calendars[name]
      @calendar = @calendars[name]
    end

    public
    def add_event(params)
      raise RuntimeError if @calendar == nil
      @calendar.add_event(Event.new(params))
      "Added #{params[:name]} to #{@calendar.name}"
    end

    public
    def get_events_with_name(name)
      raise RuntimeError unless @calendar
      format_hash_array(@calendar.events_with_name(name))
    end

    public
    def get_events_for_today
      raise RuntimeError unless @calendar
      @calendar.events_for_today.reduce({}) do |memo, (name, events)|
        memo[name.to_sym] = format_hash_array(events)
        memo
      end
    end

    public
    def get_events_for_date(date)
      raise RuntimeError unless @calendar
      @calendar.events_for_date(date).reduce({}) do |memo, (name, events)|
        memo[name.to_sym] = format_hash_array(events)
        memo
      end
    end

    public
    def get_events_for_this_week
      raise RuntimeError unless @calendar
      @calendar.events_for_this_week.reduce({}) do |memo, (name, events)|
        memo[name.to_sym] = format_hash_array(events)
        memo
      end
    end

    public
    def update_events(name, params)
      raise RuntimeError unless @calendar
      @calendar.update_events(name, params)
    end

    public
    def remove_events(name)
      raise RuntimeError unless @calendar
      @calendar.remove_events(name)
    end

    # Helpers

    private
    def format_hash_array(array)
      array.map { |event| format_hash(event.instance_values) }
    end

    private
    def format_hash(hash)
      hash.reduce({}) do |memo, (k, v)|
        memo[k.to_sym] = v if (k != 'name' && v)
        memo
      end
    end

  end

end