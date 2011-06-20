module SteppingStone
  module TextMapper
    class Context
      UndefinedMappingError = Class.new(NameError)

      def self.include_mappers(mappers)
        mappers.each { |mapper| send(:include, mapper) }
      end

      def initialize
        TextMapper.mappers.each do |mapper|
          extend(mapper)
        end

        @mappings = TextMapper.mappers.collect(&:mappings).flatten
      end

      def dispatch(action)
        if mapping = @mappings.find { |mapping| mapping.match(action) }
          mapping.dispatch(self, action)
        else
          raise UndefinedMappingError.new
        end
      end
    end
  end
end
