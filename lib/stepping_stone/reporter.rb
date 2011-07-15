require 'stepping_stone/model/event'

module SteppingStone
  class Reporter
    attr_reader :server

    def initialize(server)
      @server = server
      @results = []
    end

    def start_test(test_case)
      add_result(server.start_test(test_case))
    end

    def end_test(test_case)
      add_result(server.end_test(test_case))
    end

    def dispatch(action)
      add_result(server.dispatch(action))
    end

    def add_result(result)
      @results << result
    end

    # FIXME: Remove this shit alongside the Action primitive obsession
    def events
      @results.map do |result|
        if result.status == :event
          [result.action, result.value]
        elsif result.status == :passed
          [:dispatch, result.action[0]]
        end
      end
    end

    def to_s
      @results.map do |result|
        case result.status
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
        when :event
          # no-op while we refactor
        else
          raise "This should never happen"
        end
      end.join
    end
  end
end
