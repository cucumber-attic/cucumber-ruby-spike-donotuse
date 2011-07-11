module SteppingStone
  class Reporter
    attr_reader :server, :events

    def initialize(server)
      @server = server
      @results = []
      @events = []
    end

    def start_test(test_case)
      event(:before, server.start_test(test_case))
    end

    def end_test(test_case)
      event(:after, server.end_test(test_case))
    end

    def dispatch(action)
      add_result(server.dispatch(action))
      event(:dispatch, action[0])
    end

    def add_result(result)
      @results << result
    end

    def to_s
      @results.map do |result|
        case result.result
        when :pending
          "P"
        when :passed
          "."
        when :failed
          "F"
        when :undefined
          "U"
        when :skipped
          "S"
        else
          raise "This should never happen"
        end
      end.join
    end

    private

    def event(name, value)
      events << [name, value]
    end
  end
end
