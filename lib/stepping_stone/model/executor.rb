module SteppingStone
  module Model
    class Executor
      attr_reader :server

      def initialize(server)
        @server = server
      end

      def execute(test_case)
        server.start_test(test_case) do |session|
          @last_event = session.setup
          test_case.each do |action|
            if skip?
              session.skip(action)
            else
              session.before_apply(action)
              @last_event = session.apply(action)
              session.after_apply(action)
            end
          end
          session.teardown
        end
      end

      def skip?
        @last_event == :failed or @last_event == :undefined
      end
    end
  end
end
