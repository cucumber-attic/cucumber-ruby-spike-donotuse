module SteppingStone
  class Reporter
    attr_reader :server

    def initialize(server)
      @server = server
      @results = []
    end

    def start_test(test_case)
      server.start_test(test_case)
    end

    def end_test(test_case)
      server.end_test(test_case)
    end

    def dispatch(action, &block)
      server.dispatch(action, &block)
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
  end
end
