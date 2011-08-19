module SteppingStone
  module Model
    class Result
      attr_reader :status, :value

      def initialize(status, value=nil)
        @status = status
        @value = value
      end

      def passed?
        status == :passed
      end

      def undefined?
        status == :undefined
      end

      def failed?
        status == :failed
      end

      def skipped?
        status == :skipped
      end

      def ==(obj)
        value == obj
      end
    end
  end
end
