module SteppingStone
  module TextMapper
    class Context
      UndefinedMappingError = Class.new(NameError)

      def initialize
        TextMapper.mappers.each do |mapper|
          extend(mapper)
        end

        @mappings = TextMapper.mappers.collect(&:mappings).flatten
      end

      def dispatch(action)
        # A proper mapping collection could support a find! method that would raise on its own
        mapping = @mappings.find { |mapping| mapping.match(action) } or raise UndefinedMappingError.new
        mapping.dispatch(self, action)
      end
    end
  end
end
