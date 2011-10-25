require 'date'

module SteppingStone
  module Model
    class Result
      EVENT_ERRORS    = [:failed, :pending] 
      DISPATCH_ERRORS = [:failed, :pending, :undefined, :skipped]
      
      attr_reader :status, :value, :instruction, :created_at

      def initialize(status, value=nil, instruction=nil)
        @status = status
        @value = value
        @instruction = instruction
        @created_at = DateTime.now
      end

      def event
        @instruction.name
      end

      def arguments
        @instruction.arguments
      end

      def important?
        response_required? or !undefined?
      end
      
      def response_required?
        @instruction.name == :map
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
        value == obj
      end

      def to_a
        [event, arguments, status]
      end
    end
  end
end
