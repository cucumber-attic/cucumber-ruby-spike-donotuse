module SteppingStone
  class Pattern
    attr_reader :pattern

    def initialize(pattern)
      @pattern = pattern
    end

    def match(target)
      self.===(target)
    end

    def ===(target)
      pattern === target
    end

    def to_s
      "#{self.class}: '#{pattern}'"
    end
  end
end
