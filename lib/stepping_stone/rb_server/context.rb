module SteppingStone
  class RbServer
    class Context
      def self.include_mappers(mappers)
        mappers.each { |mapper| send(:include, mapper) }
      end

      def dispatch(action)
        # dispatch
      end
    end
  end
end
