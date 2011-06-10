module SteppingStone
  module TextMapper
    class Context
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
          begin
            mapping.dispatch(self, action)
            :passed
          rescue RSpec::Expectations::ExpectationNotMetError
            :failed
          end
        else
          :missing
        end
      end
    end
  end
end
