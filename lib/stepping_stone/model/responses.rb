require 'forwardable'
require 'date'

module SteppingStone
  module Model
    class Response
      extend Forwardable

      attr_reader :type, :name, :result, :created_at

      def initialize(type, name, result)
        @type, @name, @result = type, [name].flatten, result
        @created_at = DateTime.now
      end

      def_delegators :@result, :passed?, :failed?, :undefined?, :skipped?, :status

      def halt?
        failed?
      end

      def important?
        !undefined?
      end

      def to_a
        [type, name, status]
      end

      def to_s
        ""
      end
    end

    class ActionResponse < Response
      def halt?
        failed? or undefined? or skipped?
      end

      def important?
        true
      end

      def to_s
        {
          :passed    => ".",
          :failed    => "F",
          :undefined => "U",
          :skipped   => "S"
        }[status]
      end
    end
  end
end

