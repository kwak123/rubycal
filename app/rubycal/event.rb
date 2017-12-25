module RubyCal

  # Requirements
    # Events must have a name and a start time
    # Events must have an end time or be flagged as an all-day event

  # Implementation
    # Instead of an all-day flag, I will use end_time as an optional
    # If no end_time is provided, it is assumed that the event is all-day
      # Thought is if I want to update time, less chance of forgetting the all-day flag

  # On the docket:
    # Clean up these long unless statements
    # End time should not be before start time

  class Event
    attr_accessor :name, :start_time, :end_time, :location

    def initialize(params)
      raise ArgumentError, 'Name required' unless (params[:name].kind_of? String) && (params[:name].length > 0)
      raise ArgumentError, "Invalid start time, received #{params[:start_time]}" unless params[:start_time].kind_of? Time
      raise ArgumentError, "Invalid location" unless (params[:location] == nil) || (params[:location].instance_of? RubyCal::Location)
      @name = params[:name]
      @start_time = params[:start_time]
      @end_time = params[:end_time]
      @location = params[:location]
    end

    public
    def update_event(params)
      verify_params(params)
      params.each do |k, v|
        self.instance_variable_set("@#{k}", v)
      end
    end

    private
    def verify_params(params)
      params.each do |k, v|
        case k
          when :name
            raise ArgumentError unless (params[:name].kind_of? String) && (params[:name].length > 0)
          when :start_time
            raise ArgumentError, "Invalid start time, received #{params[:start_time]}" unless params[:start_time].kind_of? Time
          when :end_time
            raise ArgumentError, "Invalid end time, received #{params[:end_time]}" unless params[:start_time].kind_of? Time
          when :location
            raise ArgumentError, "Invalid location" unless params[:location].instance_of? RubyCal::Location
          end
        end
    end

  end

end