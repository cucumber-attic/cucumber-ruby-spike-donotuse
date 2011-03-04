module SteppingStone
  class Pattern
    
    def self.[](*parts)
      new(*parts)
    end

    attr_reader :parts

    def initialize(*parts)
      @parts = parts
    end

    def match(target)
      self.===(target)
    end

    def ===(target)
      if parts.length == 1
        compare(parts, [target])
      else
        compare(parts, target)
      end
    end

    def to_s
      "#{self.class}: '#{parts}'"
    end
    
    private

    def compare(parts, targets, last=nil)
      return last unless part = parts[0] and target = targets[0]
      current = (part === target)
      return false unless current
      compare(parts[1..-1], targets[1..-1], current)
    end

  end
end
