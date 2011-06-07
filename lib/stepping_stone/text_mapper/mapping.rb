require 'stepping_stone/pattern'

module SteppingStone
  module TextMapper
    class Mapping
      def self.build(dsl_args)
        from, to = dsl_args.shift
        new(from, to)
      end

      attr_accessor :from, :to

      def initialize(from, to)
        @from = from
        @to = to # MethodSignature.new(to) ???
        @pattern = Pattern.new(from)
      end

      def match(pattern)
        @pattern === pattern
      end

      def captures_from(str)
        if match = Regexp.new(from).match(str)
          match.captures
        else
          []
        end
      end

      def dispatch(target, action="")
        args = captures_from(action)
        target.send(to, *args)
      end
    end
  end
end
