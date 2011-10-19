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

    def passed?
      history.all?(&:passed?)
    end

    def failed?
      history.any?(&:failed?)
    end

    def pending?
      history.any?(&:pending?)
    end

    def undefined?
      history.any?(&:undefined?)
    end

    def write(out)
      history.each do |ev|
        if ev.response_required?
          letter = {
            :passed    => ".",
            :failed    => "F",
            :undefined => "U",
            :skipped   => "S",
            :pending   => "P"
          }[ev.status]
          out.write(letter)
        end
      end
    end
  end
end
