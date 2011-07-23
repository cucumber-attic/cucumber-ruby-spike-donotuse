module SteppingStone
  module Model
    class Executor
      attr_reader :server

      def initialize(server)
        @server = server
      end

      def execute(test_case)
        server.start_test(test_case) do |session|
          session.setup
          test_case.each do |action|
            if skip?
              session.skip(action)
            else
              @last_event = session.apply(action)
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
