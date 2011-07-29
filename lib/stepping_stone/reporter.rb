require 'stepping_stone/model/event'

module SteppingStone
  class Reporter
    class SessionRecorder
      attr_reader :session, :reporter

      def initialize(session, reporter)
        @session = session
        @reporter = reporter
      end

      def setup
        add(session.setup)
      end

      def teardown
        add(session.teardown)
      end

      def apply(action)
        add(session.apply(action))
      end

      def before_apply(action)
        add(session.before_apply(action))
      end

      def after_apply(action)
        add(session.before_apply(action))
      end

      def skip(action)
        add(session.skip(action))
      end

      def add(event)
        reporter.add_result(event)
      end
    end

    attr_reader :server

    def initialize(server)
      @server = server
      @results = []
    end

    def start_test(test_case, &execution_script)
      server.start_test(test_case) do |session|
        execution_script.call(SessionRecorder.new(session, self))
      end
    end

    def add_result(result)
      @results << result
      result
    end

    def events
      # TODO: Add a #to_a or #to_sexp method to Event
      @results.reject(&:no_op?).map do |result|
        [result.type, result.name, result.status]
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
        when :event, :no_op
          # no-op while we refactor
        else
          raise "This should never happen"
        end
      end.join
    end
  end
end
