require 'observer'

require 'stepping_stone/model/run_result'

module SteppingStone
  class Reporter
    class TestCaseResult
      include Enumerable

      attr_reader :id, :events

      def initialize(id)
        @id = id
        @events = []
      end

      def each(&enum)
        @events.each(&enum)
      end

      def add(event)
        @events << event
      end

      def status
        return :passed if @events.all?(&:passed?)
        return :failed if @events.any?(&:failed?)
        return :undefined if @events.any?(&:undefined?)
        return :pending if @events.any?(&:pending?)
      end

      def passed?
        status == :passed
      end

      def failed?
        status == :failed
      end

      def undefined?
        status == :undefined
      end

      def pending?
        status == :pending
      end
    end

    include Observable

    def initialize
      @run = Model::RunResult.new
    end

    def record(event)
      @last_event = event
      case event.name
      when :setup
        @result = TestCaseResult.new(event.arguments[0])
      when :teardown
        @run.add(@result)
        @result = nil
      else
        @result.add(event)
      end
    end

    def record_run
      @run.start_run
      changed
      notify_observers(:start_run)

      yield

      @run.add(@result) if @result

      @run.end_run
      changed
      notify_observers(:end_run)
    end

    def broadcast(result)
      record(result)
      changed
      notify_observers(:event) if result.important?
    end

    def last_event
      @last_event
    end

    def status_of(id)
      @run.status_of(id)
    end

    def summary
      {
        start_time:   @run.started_at,
        end_time:     @run.ended_at,

        test_cases:   { total: @run.count,
                        passed: @run.count(&:passed?),
                        failed: @run.count(&:failed?),
                        undefined: @run.count(&:undefined?) },

        instructions: { total: @run.inject(0) { |sum, res| sum + res.count },
                        passed: @run.inject(0) { |sum, res| sum + res.count(&:passed?) },
                        failed: @run.inject(0) { |sum, res| sum + res.count(&:failed?) },
                        undefined: @run.inject(0) { |sum, res| sum + res.count(&:undefined?) },
                        skipped: @run.inject(0) { |sum, res| sum + res.count(&:skipped?) } }
      }
    end
  end
end
