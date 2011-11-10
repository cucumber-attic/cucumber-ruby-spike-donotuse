require 'observer'

require 'stepping_stone/model/run_result'

module SteppingStone
  class Reporter
    class Result
      attr_reader :id, :events

      def initialize(id)
        @id = id
        @events = []
      end

      def record(event)
        @events << event
      end

      def last
        @events.last
      end

      def steps
        @events.select { |event| ![:setup, :teardown].include?(event.name) }
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

    attr_reader :results

    def initialize
      @results = []
      @runs = []
    end

    def record(event)
      @last_event = event
      case event.name
      when :setup
        @result = Result.new(event.arguments[0])
      when :teardown
        @results.push(@result)
        @result = nil
      else
        @result.record(event)
      end
    end

    def record_run
      run = Model::RunResult.new
      @runs.push(run)
      run.start_run
      changed
      notify_observers(:start_run)

      yield

      @results.push(@result) if @result
      run.end_run
      changed
      notify_observers(:end_run)
    end

    def broadcast(result)
      record(result)
      changed
      notify_observers(:event) if result.important?
    end

    def last_run
      @runs.last
    end

    def last_event
      @last_event
    end

    def status_of(id)
      @results.find { |res| res.id == id }.status
    end

    def summary
      {
        start_time:   last_run.started_at,
        end_time:     last_run.ended_at,

        test_cases:   { total: @results.count,
                        passed: @results.select(&:passed?).count,
                        failed: @results.select(&:failed?).count,
                        undefined: @results.select(&:undefined?).count },

        instructions: { total: @results.inject(0) { |sum, res| sum + res.steps.count },
                        passed: @results.inject(0) { |sum, res| sum + res.steps.count(&:passed?) },
                        failed: @results.inject(0) { |sum, res| sum + res.steps.count(&:failed?) },
                        undefined: @results.inject(0) { |sum, res| sum + res.steps.count(&:undefined?) },
                        skipped: @results.inject(0) { |sum, res| sum + res.steps.count(&:skipped?) } }
      }
    end
  end
end
