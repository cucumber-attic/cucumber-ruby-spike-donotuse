module SteppingStone
  class RbServer
    class Context
      def self.include_mappers(mappers)
        mappers.each { |mapper| send(:include, mapper) }
      end

      def initialize
        TextMapper.mappers.each do |mapper|
          extend(mapper)
        end

        @mappings = TextMapper.mappers.collect(&:mappings)
      end

      def dispatch(action)
        if mapping = @mappings[0].find { |from, _| action.to_s =~ Regexp.new(from) }
          :passed
        else
          :pending
        end
      end
    end
  end
end
