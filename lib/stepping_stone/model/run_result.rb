module SteppingStone
  module Model
    class RunResult
      attr_reader :started_at, :ended_at

      def start_run
        @started_at = Time.now
      end

      def end_run
        @ended_at = Time.now
      end

      def duration
        @ended_at - @started_at
      end
    end
  end
end
