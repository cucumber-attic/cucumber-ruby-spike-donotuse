require 'stepping_stone/model/request'

module SteppingStone
  class Runner
    module RequestRunner
      def each
        super { |instruction| yield Model::Request.new(*instruction) }
      end

      def run(*args, &block)
        inject(*args, &block)
      end
    end

    attr_reader :server, :broker, :decorator

    def initialize(server, broker, decorator = RequestRunner)
      @server, @broker, @decorator = server, broker, decorator
    end

    def execute(test_case)
      test_case.extend(decorator)
      server.start_test(test_case) do |session| 
        test_case.run(:continue) do |state, request|
          case state
          when :continue
            response = session.perform(request)
            broker.broadcast(response)
            response.halt? ? :skip : :continue
          when :skip
            broker.broadcast_skip(request)
            :skip
          end
        end
      end
    end
  end
end
