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

        #send(meth_name, *arguments)

        if mapping = @mappings[0].find { |from, _| action.to_s =~ Regexp.new(from) }
          from, to = mapping
          meth_name, arg_types = to
          captures = Regexp.new(from).match(action.to_s).captures
          begin
            send(meth_name, *captures)
            :passed
          rescue RSpec::Expectations::ExpectationNotMetError
            :failed
          end
        else
          :pending
        end
      end
    end
  end
end
