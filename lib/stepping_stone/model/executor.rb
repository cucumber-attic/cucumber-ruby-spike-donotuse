module SteppingStone
  module Model
    class Executor
      attr_reader :server

      def initialize(server)
        @server = server
      end

      def execute(test_case)
        if !test_case.empty?
          server.start_test(test_case)
          test_case.each do |action|
            server.dispatch(action)
          end
          server.end_test(test_case)
        end
      end
    end
  end
end
