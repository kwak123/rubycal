require 'active_support'
require 'active_support/core_ext'

module RubyCal

  # Requirements
    # Method requirements written above methods
    # Must have a name

  # Implementation
    # Done as per the requirements
    # Names were chose for hashes, as specifications cite multiple all-event methods
      # To simplify removing multiple of a hash
    # Arrays are used as buckets to support multiple events with same name

  DATE_COMPARER = Proc.new do |t1, t2|
    raise ArgumentError, 'Invalid Time' unless (t1.instance_of? Time) && (t2.instance_of? Time)
    t1.year == t2.year && t1.month == t2.month && t1.day == t2.day
  end

  WEEK_COMPARER = Proc.new do |t1, t2|
    raise ArgumentError, 'Invalid Time' unless (t1.instance_of? Time) && (t2.instance_of? Time)
    week = 60 * 60 * 24 * 7
    t1 > t2 ? t1 < t2 + week : t2 < t1 + week
  end

  class Calendar
    attr_reader :name

    # events – Returns all events for the calendar.
    attr_accessor :events

    def initialize(name)
      raise ArgumentError, 'Calendar name is missing' unless (name.length > 0) && (name.kind_of? String)
      @name = name
      @events = {}
    end

    # add_event(name, params) – Adds an event to the calendar.
    # expect p to be optional event params
    public
    def add_event(event)
      raise ArgumentError, 'add_event requires a RubyCal::Event object' unless event.instance_of? Event
      @events[event.name] = @events[event.name] ? @events[event.name] << event : [event]
    end

    # events_with_name(name) – Returns events matching the given name.
      # Returning array because name is the separating value
    public
    def events_with_name(name)
      raise NameError, 'No events found with that name' unless @events[name]
      @events[name]
    end

    # events_for_today – Returns events that occur today.
    public
    def events_for_today
      today = Time.now
      result = {}
      @events.each do |name, bucket|
        temp = bucket.select { |event| DATE_COMPARER.call(event.start_time, today) }
        result[name] = temp if temp.length > 0
      end
      raise 'No events found for today' unless result.length > 0
      result
    end

    # events_for_date(date) – Returns events that occur during the given date.
    public
    def events_for_date(date)
      result = {}
      @events.each do |name, bucket|
        temp = bucket.select { |event| DATE_COMPARER.call(event.start_time, date) }
        result[name] = temp if temp.length > 0
      end
      raise "No events found for #{date.strftime('%b, %-d, %Y')}" unless result.length > 0
      result
    end

    # events_for_this_week – Returns events that occur within the next 7 days.
    public
    def events_for_this_week
      today = Time.now
      result = {}
      @events.each do |name, bucket|
        temp = bucket.select { |event| WEEK_COMPARER.call(event.start_time, today) }
        result[name] = temp if temp.length > 0
      end
      raise 'No events found for this week' unless result.length > 0
      result
    end

    # update_events(name, params) – For all calendar events matching the given name, then update the event's attributes based on the given params.
    public
    def update_events(name, params)
      raise NameError, 'No event(s) by that name' unless @events[name]
      if params[:name]
        raise NameError, 'Event already exists with that name!' if @events[params[:name]]
        @events[params[:name]] = @events[name].deep_dup
        @events.delete(name)
        name = params[:name]
      end
      @events[name].each { |x| x.update_event(params) }
      @events[name].length
    end

    # remove_events(name) – Removes calendar events with the given name.
    public
    def remove_events(name)
      raise NameError, 'No event(s) by that name' unless @events[name]
      prev_length = @events[name].length
      @events.delete(name)
      prev_length
    end
  end
end