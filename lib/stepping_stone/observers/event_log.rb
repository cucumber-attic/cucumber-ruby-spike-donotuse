module SteppingStone
  module Observers
    class EventLog
      include Enumerable

      def initialize(reporter)
        reporter.add_observer(self)
        @reporter = reporter
        @events = []
      end

      def update(type)
        if type == :event
          add(@reporter.last_event)
        end
      end

      def each(&block)
        @events.each(&block)
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
    end
  end
end
