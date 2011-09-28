require 'observer'
require 'stepping_stone/model/result'
require 'stepping_stone/model/responses'

module SteppingStone
  module Model
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
              response = handle(session, request)
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
        if request.event == :apply
          response = ActionResponse.new(:skip, request.action, Model::Result.new(:skipped))
          broadcast(response)
        end
      end

      def handle(session, request)
        session.send(request.event, *request.action)
      end
    end
  end
end
