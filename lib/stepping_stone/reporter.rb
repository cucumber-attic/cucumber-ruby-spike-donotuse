require 'stepping_stone/model/event'

module SteppingStone
  class Reporter
    attr_reader :server

    def initialize(server)
      @server = server
      @results = []
    end

    def start_test(test_case)
      build_result(:before, :event, server.start_test(test_case))
    end

    def end_test(test_case)
      build_result(:after, :event, server.end_test(test_case))
    end

    def dispatch(action)
      result = server.dispatch(action)
      if Model::Event === result
        add_result(result)
      else
        build_result(:dispatch, :event, [action, result])
      end
    end

    def add_result(result)
      @results << result
    end

    def build_result(action, status, value)
      @results << Model::Event.new(action, status, value)
    end

    # FIXME: Remove this shit alongside the Action primitive obsession
    def events
      @results.map do |result|
        if result.status == :event
          if result.action == :dispatch
            [result.action, result.value[0][0]]
          else
            [result.action, result.value]
          end
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
