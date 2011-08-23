require 'stepping_stone/model/event_log'

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

    attr_reader :server, :results

    def initialize(server)
      @server = server
      @results = Model::EventLog.new
    end

    def start_test(test_case, &execution_script)
      server.start_test(test_case) do |session|
        execution_script.call(SessionRecorder.new(session, self))
      end
    end

    def add_result(result)
      results.add(result)
    end

    def history
      results.history
    end

    def to_s
      results.to_s
    end
  end
end
