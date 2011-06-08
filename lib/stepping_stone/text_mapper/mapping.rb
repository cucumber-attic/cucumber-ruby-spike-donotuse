require 'stepping_stone/text_mapper/pattern'

module SteppingStone
  module TextMapper
    class Mapping
      def self.from_fluent(dsl_args)
        from, to = dsl_args.shift
        meth_name, *types = to
        new(from, meth_name, types)
      end

      attr_accessor :from, :to

      def initialize(from, to, types=[])
        @from = from
        @to = to # MethodSignature.new(to) ???
        @pattern = Pattern[from]
        @types = types
      end

      def match(pattern)
        @pattern === pattern.to_a
      end

      def captures_from(str)
        # TODO: Remove Regexp once the Pattern class can extract variables from applied
        # target patterns
        if match = Regexp.new(from).match(str)
          if @types.empty?
            match.captures
          else
            match.captures.zip(@types).collect do |capture, type|
              # FIXME: Add other built-ins with idiosyncratic build protocols
              if Integer == type
                capture.to_i
              elsif Float == type
                capture.to_f
              else
                type.new(capture)
              end
            end
          end
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
