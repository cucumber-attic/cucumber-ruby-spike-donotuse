require 'observer'
require 'stepping_stone/model/responder'
require 'stepping_stone/model/result'

module SteppingStone
  module Model
    class Executor
      include Observable

      attr_reader :server
      attr_reader :responder

      def initialize(server)
        @server = server
        @responder = Model::Responder.new
      end

      def execute(test_case)
        server.start_test(test_case) do |session|
          @last_event = session.setup

          test_case.each do |action|
            if @last_event.skip_next?
              broadcast(responder.skip(action, Model::Result.new(:skipped)))
            else
              session.before_apply(action)
              @last_event = session.apply(action)
              session.after_apply(action)
            end
          end

          unless @last_event.skip_next?
            session.teardown
          end
        end
      end

      def broadcast(msg)
        changed
        notify_observers(msg)
      end
    end
  end
end
