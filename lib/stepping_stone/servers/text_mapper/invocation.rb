module SteppingStone
  module Servers
    class TextMapper
      class Invocation
        attr_reader :mappings

        def initialize(mappings)
          @mappings = mappings
        end

        def call(ctx, pattern)
          mappings.inject({}) do |results, mapping|
            results.merge({ mapping.id => mapping.call(ctx, pattern) })
          end
        end

        def id
          object.id
        end
      end
    end
  end
end
