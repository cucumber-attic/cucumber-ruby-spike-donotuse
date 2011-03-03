module SteppingStone
  class Pattern
    def initialize(pattern)
      @pattern = pattern
    end

    def match(target)
      self.===(target) 
    end

    def ===(target)
      @pattern === target
    end
  end
end
