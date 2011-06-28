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
    end
  end
end
