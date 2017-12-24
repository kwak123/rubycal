module RubyCal

  # Requirements
    # Location must have a name 
    # Optionals are address, city, state, and zip
  
  # Implementation
    # Done as per the requirements

  class Location
    attr_accessor :name, :address, :city, :state, :zip

    def initialize(params)
      raise ArgumentError, 'Name required' unless (params[:name].kind_of? String) && (params[:name].length > 0)
      @name = params[:name]
      @address = params[:address]
      @city = params[:city]
      @state = params[:state]
      @zip = params[:zip]
    end

    # Raise error for poorly formatted params, or ignore?
    public
    def update_location(params)
      params.each do |k, v|
        self.instance_variable_set("@#{k}", v)
      end
    end

  end

end