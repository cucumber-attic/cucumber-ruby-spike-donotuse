require 'observer'

require 'stepping_stone/model/request'
require 'stepping_stone/model/response'
require 'stepping_stone/model/result'

module SteppingStone
  class Runner
    module RequestSynthesizer
      def each
        Model::Request.new(:setup, [name])
        yield Model::Request.new(:setup, [name])
        super { |instruction| yield Model::Request.required(:map, instruction) }
        yield Model::Request.new(:teardown, [name])
      end
    end

    include Observable

    attr_reader :server

    def initialize(server)
      @server = server
    end

    def execute(test_case)
      test_case.extend(RequestSynthesizer)
      server.start_test(test_case) do |session|
        test_case.inject(:continue) do |state, request|
          case state
          when :continue
            response = session.perform(request)
            broadcast(response)
            response.halt? ? :skip : :continue
          when :skip
            broadcast_skip(request)
            :skip
          end
        end
      end
    end

    private

    def broadcast(response)
      changed
      notify_observers(response)
    end

    def broadcast_skip(request)
      if request.event == :map
        response = Model::Response.new(request, Model::Result.new(:skipped))
        broadcast(response)
      end
    end
  end
end
