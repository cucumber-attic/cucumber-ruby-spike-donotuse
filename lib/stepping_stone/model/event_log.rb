require 'stepping_stone/model/events'

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

      def types
        events.map(&:type)
      end

      def statuses
        events.reject do |event|
          Events::HookEvent === event and
            event.undefined?
        end.map(&:status)
      end

      def executed_events
        events.reject(&:undefined?).map do |result|
          # TODO: Add a #to_a or #to_sexp method to Event
          [result.type, result.name, result.status]
        end
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
        @events.select do |event|
          Events::ActionEvent === event or
            !event.undefined?
        end
      end

      def to_s
        events.map(&:to_s).join
      end
    end
  end
end
