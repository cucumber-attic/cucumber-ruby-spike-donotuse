require 'forwardable'
require 'date'

module SteppingStone
  module Model
    class Response
      extend Forwardable

      def_delegators :@request, :event, :arguments, :response_required?
      def_delegators :@result, :passed?, :failed?, :undefined?, :skipped?, :pending?, :status

      attr_reader :created_at

      def initialize(request, result)
        @request, @result = request, result
        @created_at = DateTime.now
      end

      def halt?
        if response_required?
          failed? or undefined? or skipped? or pending?
        else
          failed? or pending?
        end
      end

      def important?
        response_required? or !undefined?
      end

      def to_a
        [event, arguments, status]
      end
    end
  end
end

