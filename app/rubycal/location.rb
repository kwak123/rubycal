module RubyCal

  # Requirements
    # Location must have a name 
    # Optionals are address, city, state, and zip
  
  # Implementation
    # Done as per the requirements

  # On the docket:
    # Type check this data
      # Zip should be parseable as a number
      # Empty inputs are invalid
  
  # Future considerations?
    # Validate inputs completely, e.g. city should exist, state should be real

  class Location
    attr_reader :name, :address, :city, :state, :zip

    def initialize(params)
      raise ArgumentError, "Location requires name" unless (params[:name].kind_of? String) && (params[:name].length > 0)
      @name = params[:name]
      @address = params[:address]
      @city = params[:city]
      @state = params[:state]
      @zip = params[:zip]
    end

    # Raise error for poorly formatted params, or ignore?
    public
    def update_location(params)
      raise ArgumentError, "Location requires name" unless (!params[:name]) || (params[:name].kind_of? String) && (params[:name].length > 0)
      params.each do |k, v|
        self.instance_variable_set("@#{k}", v)
      end
    end

  end

end