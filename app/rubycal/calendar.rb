module RubyCal

  class Calendar

    attr_reader :name

    # events – Returns all events for the calendar.
    attr_accessor :events

    def initialize(name)
      @name = name
      @events = {}
    end

    # add_event(name, params) – Adds an event to the calendar.
    # expect p to be optional event params
    public
    def add_event(name, *p)
    end

    # events_with_name(name) – Returns events matching the given name.
    public 
    def events_with_name(name)
      @events.select { |x, y| x == name }
    end

    # events_for_date(date) – Returns events that occur during the given date.
    public
    def events_for_date(date)
    end

    # events_for_today – Returns events that occur today.
    public
    def events_for_today
    end

    # events_for_this_week – Returns events that occur within the next 7 days.
    public
    def events_for_this_week
    end

    # update_events(name, params) – For all calendar events matching the given name, then update the event's attributes based on the given params.
    public
    def update_events(name, *p)
    end

    # remove_events(name) – Removes calendar events with the given name.
    public
    def remove_events(name)
      @events.delete(name) { "#{name} is not currently in the #{@name} calendar!" }
    end

  end
end