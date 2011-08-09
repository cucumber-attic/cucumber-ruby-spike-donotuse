module SteppingStone
  module Model
    class EventLog
      attr_reader :events

      def initialize
        @events = []
      end

      def add(event)
        events << event
        event
      end

      def types
        events.map(&:type)
      end

      def statuses
        events.reject(&:undefined_hook?).map(&:status)
      end
    end
  end
end
