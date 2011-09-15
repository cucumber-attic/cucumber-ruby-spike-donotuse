module SteppingStone
  module Model
    class EventLog
      def initialize
        @events = []
      end

      def add(event)
        @events << event
        event
      end

      def events(opts={})
        filter = opts.to_a
        @events.select do |event|
          filter.all? do |attr, val|
            event.send(attr) == val
          end
        end
      end

      def history
        @events.select(&:important?)
      end

      def to_s
        events.map(&:to_s).join
      end
    end
  end
end
