module SteppingStone
  class Pattern
    def self.[](*parts)
      new(parts)
    end

    attr_reader :parts

    def initialize(parts)
      @parts = parts
    end

    def match(targets)
      self.===(targets)
    end

    def ===(targets)
      return false unless Array === targets
      compare(parts, targets)
    end

    def captures_from(targets)
      result, bindings = captures_helper(parts, targets)
      return bindings if result
    end

    def captures_helper(parts, targets, last_result=nil, captures=[])
      return [last_result, captures] unless part = parts[0] and target = targets[0]

      current_result = (part === target)
      if current_result
        captures << target if Class === part
        captures_helper(parts[1..-1], targets[1..-1], current_result, captures)
      end
    end

    def to_s
      "#{self.class}: '#{parts}'"
    end

    private

    def compare(parts, targets, last_result=nil)
      return last_result unless part = parts[0] and target = targets[0]
      current_result = (part === target)
      return false unless current_result
      compare(parts[1..-1], targets[1..-1], current_result)
    end
  end
end
