module RubyCal

  # Requirements
    # Location must have a name
    # Optionals are address, city, state, and zip

  # Implementation
    # Done as per the requirements

  # Future considerations?
    # Validate inputs completely, e.g. city should exist, state should be real

  class Location
    attr_reader :name, :address, :city, :state, :zip
    def initialize(params)
      raise ArgumentError, 'Location requires name' unless (params[:name].kind_of? String) && (params[:name].length > 0)
      @name = params[:name]
      @address = params[:address]
      @city = params[:city]
      @state = params[:state]
      @zip = params[:zip]
    end
  end
end