module SteppingStone
  module TextMapper
    class Pattern
      def self.[](*parts)
        new(parts)
      end

      attr_reader :parts

      def initialize(parts)
        @parts = parts
      end

      def match(targets)
        captures_from(targets)
      end

      def ===(targets)
        return false unless Array === targets
        result, _bindings = compare(parts, targets)
        !!result
      end

      def captures_from(targets)
        result, bindings = compare(parts, targets)
        return bindings if result
      end

      def to_s
        "#{self.class}: '#{parts}'"
      end

      private

      def compare(parts, targets, last_result=nil, captures=[])
        return [last_result, captures] if parts.length != targets.length

        return [last_result, captures] unless part = parts[0] and target = targets[0]

        current_result = (part === target)
        if current_result
          case part
          when Class
            captures.push(target)
          when Regexp
            captures.push(*part.match(target).captures)
          end
          compare(parts[1..-1], targets[1..-1], current_result, captures)
        end
      end
    end
  end
end
