require 'observer'
require 'stepping_stone/model/result'
require 'stepping_stone/model/response'

module SteppingStone
  class Executor
    include Observable

    attr_reader :server

    def initialize(server)
      @server = server
    end

    def execute(script)
      server.start_test(script.test_case) do |session|
        script.inject(:continue) do |state, request|
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
