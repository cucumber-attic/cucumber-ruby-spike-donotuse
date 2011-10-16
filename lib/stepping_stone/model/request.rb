module SteppingStone
  module Model
    class Request
      RESPONSE_REQUIRED = [:map]

      attr_reader :event, :arguments

      def initialize(event, arguments)
        @event, @arguments = event, arguments
        @response_required = RESPONSE_REQUIRED.include?(event)
      end

      def signature
        [event, *arguments]
      end

      def response_required?
        @response_required
      end
    end
  end
end
