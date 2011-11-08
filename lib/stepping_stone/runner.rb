module SteppingStone
  class Runner
    attr_reader :server, :broker, :state, :current_session

    def initialize(server, broker)
      @server, @broker = server, broker
    end

    def execute(test_case)
      server.start_test(test_case) do |session|
        @current_session = session
        test_case.each do |instruction|
          @broker.broadcast(@current_session.execute(instruction))
        end
      end
    end
  end
end
