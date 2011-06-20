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
        mapping = @mappings.find { |mapping| mapping.match(action) } or raise UndefinedMappingError.new
        mapping.dispatch(self, action)
      end
    end
  end
end
