module SteppingStone
  class Runner
    attr_reader :server, :broker, :state

    def initialize(server, broker)
      @server, @broker = server, broker
    end

    def execute(test_case)
      server.start_test(test_case) do |session|
        @state = ContinueState.new(session, broker)
        test_case.each do |instruction|
          @state.execute(instruction)
          @state = SkipState.new(session, broker) if @state.halt_execution?
        end
      end
    end

    private
    
    class State
      def initialize(session, broker)
        @session, @broker = session, broker
      end
    end
    
    class ContinueState < State
      def execute(instruction)
        @result = @session.dispatch(instruction)
        @broker.broadcast(@result)
      end

      def halt_execution?
        @result.halt?
      end
    end

    class SkipState < State
      def execute(instruction)
        @broker.broadcast_skip(instruction)
      end

      def halt_execution?
        true
      end
    end
  end
end
