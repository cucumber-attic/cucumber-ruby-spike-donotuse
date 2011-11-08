module SteppingStone
  class Configuration
    attr_accessor :compiler, :server

    def initialize
      @compiler = :gherkin
      @server   = :text_mapper
    end

    def global
      @global ||= {}
    end
  end
end
