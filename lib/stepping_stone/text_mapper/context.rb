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
        mapping = mappings.find_hook([:setup, :test_case])
        mapping.call(self, test_case)
      end

      def teardown(test_case)
        mapping = mappings.find_hook([:teardown, :test_case])
        mapping.call(self, test_case)
      end
    end
  end
end
