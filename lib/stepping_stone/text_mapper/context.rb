module SteppingStone
  module TextMapper
    class Context
      attr_reader :mappings

      def initialize(mappings, mappers=[])
        mappers.each { |mapper| extend(mapper) }
        @mappings = mappings
      end

      def dispatch(action)
        mapping = mappings.find_mapping(action)
        mapping.call(self, action)
      end

      def setup(test_case)
        if mapping = mappings.find_hook([:before, :test_case])
          mapping.call(self, test_case)
        end
      end

      def teardown(test_case)
        if mapping = mappings.find_hook([:after, :test_case])
          mapping.call(self, test_case)
        end
      end
    end
  end
end
