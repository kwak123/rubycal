module RubyCal

  class Calendar
    attr_reader :name
    attr_accessor :storage
    def initialize(name)
      @name = name
      @storage = {}
    end
  end

end