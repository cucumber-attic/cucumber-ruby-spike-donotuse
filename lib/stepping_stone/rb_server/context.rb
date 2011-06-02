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

        @mappings = TextMapper.mappers.collect(&:mappings).flatten
      end

      def dispatch(action)
        #from, to             = mappings.find{ |regex, _| action =~ regex }
        #meth_name, arg_types = to
        #captures             = from.match(action).captures

        #arguments = if !arg_types.empty?
          #captures.zip(arg_types).collect do |capture, type|
            #if type == Integer
              #capture.to_i
            #else
              #type.new(capture)
            #end
          #end
        #else
          #captures
        #end

        if mapping = @mappings.find { |mapping| mapping.match(action.elements) }
          begin
            send(mapping.to, *mapping.captures_from(action.to_s))
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
