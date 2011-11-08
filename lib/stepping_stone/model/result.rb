require 'date'

module SteppingStone
  module Model
    class Result
      KNOWN_STATUSES  = [:passed, :failed, :undefined, :skipped, :pending]
      EVENT_ERRORS    = [:failed, :pending]
      DISPATCH_ERRORS = [:failed, :pending, :undefined, :skipped]

      attr_reader :instruction, :status, :value, :created_at

      def initialize(instruction, status, value={})
        ensure_known_status(status)
        @instruction = instruction
        @status      = status
        @value       = value
        @created_at  = DateTime.now
      end

      def name
        @instruction.name
      end

      def arguments
        @instruction.arguments
      end

      def response_required?
        @instruction.response_required?
      end

      def important?
        response_required? or !undefined?
      end

      def halt?
        if response_required?
          DISPATCH_ERRORS.include?(@status)
        else
          EVENT_ERRORS.include?(@status)
        end
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

      def pending?
        status == :pending
      end

      def ==(obj)
        @instruction == obj.instruction and
        @status == obj.status and
        @value == obj.value
      end

      def to_a
        [event, arguments, status, value]
      end

      private

      def ensure_known_status(status)
        raise ArgumentError, "Unknown status '#{status}'" unless KNOWN_STATUSES.include?(status)
      end
    end
  end
end
