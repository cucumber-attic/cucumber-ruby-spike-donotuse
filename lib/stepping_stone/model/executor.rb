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
            break if session.apply(action) == :fail
          end
          session.teardown
        end
      end
    end
  end
end
