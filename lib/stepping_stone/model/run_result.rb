module SteppingStone
  module Model
    class RunResult
      include Enumerable

      attr_reader :started_at, :ended_at

      def initialize
        @results = []
      end

      def each(&enum)
        @results.each(&enum)
      end

      def start_run
        @started_at = Time.now
      end

      def end_run
        @ended_at = Time.now
      end

      def duration
        @ended_at - @started_at
      end

      def add(result)
        @results.push(result)
      end

      def status
        statuses = @results.collect(&:status).uniq
        statuses.include?(:failed) ? :failed : :passed
      end

      def result_count
        @results.length
      end

      def status_of(id)
        if result = @results.find { |result| result.id == id }
          result.status
        end
      end
    end
  end
end
