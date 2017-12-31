require 'active_support'
require 'active_support/core_ext'

require_relative 'calendar'
require_relative 'event'
require_relative 'location'

module RubyCal

  # Requirements
    # None

  # Implementation
    # App will be responsible for RubyCal API
    # App will also format expose friendlier responses to get requests

  class App

    attr_reader :calendars, :calendar

    def initialize
      @calendars = {}
    end

    public
    def add_cal(name)
      raise NameError, "Calendar already exists!" if @calendars[name]
      @calendars[name] = Calendar.new(name)
    end

    public
    def use_cal(name)
      raise NameError, "No calendar by that name!" unless @calendars[name]
      @calendar = @calendars[name]
    end

    public
    def get_cals
      @calendars.reduce([]) do |memo, (k, v)|
        memo << k
        memo
      end
    end

    public
    def add_event(params)
      raise RuntimeError, "Set a calendar first!" if @calendar == nil
      params[:location] = Location.new(params[:location]) if params[:location]
      @calendar.add_event(Event.new(params))
      "Added #{params[:name]} to #{@calendar.name}"
    end

    public
    def get_events
      raise RuntimeError, "Set a calendar first!" if @calendar == nil
      @calendar.events.reduce({}) do |memo, (name, events)| 
        memo[name.to_sym] = format_hash_array(events)
        memo
      end
    end

    public
    def get_events_with_name(name)
      raise RuntimeError, "Set a calendar first!" unless @calendar
      format_hash_array(@calendar.events_with_name(name))
    end

    public
    def get_events_for_today
      raise RuntimeError, "Set a calendar first!" unless @calendar
      @calendar.events_for_today.reduce({}) do |memo, (name, events)|
        memo[name.to_sym] = format_hash_array(events)
        memo
      end
    end

    public
    def get_events_for_date(date)
      raise RuntimeError, "Set a calendar first!" unless @calendar
      @calendar.events_for_date(date).reduce({}) do |memo, (name, events)|
        memo[name.to_sym] = format_hash_array(events)
        memo
      end
    end

    public
    def get_events_for_this_week
      raise RuntimeError, "Set a calendar first!" unless @calendar
      @calendar.events_for_this_week.reduce({}) do |memo, (name, events)|
        memo[name.to_sym] = format_hash_array(events)
        memo
      end
    end

    public
    def update_events(name, params)
      raise RuntimeError, "Set a calendar first!" unless @calendar
      if params[:location]
        temp_loc_vals = @calendar.events_with_name(name)[0].location.instance_values.symbolize_keys
        new_loc = Location.new(temp_loc_vals.merge(params[:location]))
        params[:location] = new_loc
      end
      @calendar.update_events(name, params)
    end

    public
    def remove_events(name)
      raise RuntimeError, "Set a calendar first!" unless @calendar
      @calendar.remove_events(name)
    end

    # Helpers

    private
    def format_hash_array(array)
      array.map { |event| format_hash(event.instance_values) }
    end

    private
    def format_hash(hash, is_loc = false)
      hash.reduce({}) do |memo, (k, v)|
        if (is_loc ? v : k != 'name' && v)
          memo[k.to_sym] = v.instance_of?(Location) ? format_hash(v.instance_values, true) : v
        end
        memo
      end
    end

  end

end