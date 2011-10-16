require 'stepping_stone/event_log'

module SteppingStone
  class Reporter
    attr_reader :log

    def initialize(broadcaster)
      broadcaster.add_observer(self)
      @log = EventLog.new
    end

    def update(event)
      log.add(event)
    end

    def history
      log.history
    end

    def to_s
      log.to_s
    end
  end
end
