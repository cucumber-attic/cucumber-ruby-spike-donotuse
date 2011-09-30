module SteppingStone
  module Model
    class Request
      def self.required(event, arguments)
        self.new(event, arguments, true)
      end

      attr_reader :event, :arguments

      def initialize(event, arguments, response_required=false)
        @event, @arguments, @response_required = event, arguments, response_required
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
