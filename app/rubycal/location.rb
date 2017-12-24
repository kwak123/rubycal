module RubyCal
  class Location
    attr_accessor :name

    def initialize(name, address = false, city = false, state = false, zip = false)
      @name = name
      @address = address
      @city = city
      @state = state
      @zip = zip
    end
  end
end