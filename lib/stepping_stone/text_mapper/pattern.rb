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
        return false unless targets.respond_to?(:to_a)
        result, bindings = compare(parts, targets.to_a)
        return bindings if result
      end

      def ===(targets)
        !!match(targets)
      end

      def to_s
        "#{self.class}: '#{parts}'"
      end

      private

      def compare(parts, targets, last_result=nil, captures=[])
        return [last_result, captures] if parts.length != targets.length
        return [last_result, captures] unless part = parts[0] and target = targets[0]

        if current_result = (part === target)
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
