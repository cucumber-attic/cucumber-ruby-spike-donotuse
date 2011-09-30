require 'stepping_stone/event_log'

module SteppingStone
  class Reporter
    attr_reader :results

    def initialize(broadcaster)
      broadcaster.add_observer(self)
      @results = EventLog.new
    end

    def update(result)
      results.add(result)
    end

    def history
      results.history
    end

    def to_s
      results.to_s
    end
  end
end
