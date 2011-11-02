require 'observer'
require 'stepping_stone/event_log'
require 'stepping_stone/model/result'

module SteppingStone
  class Reporter
    class Result
      attr_reader :id

      def initialize(id)
        @id = id
        @events = []
      end

      def record(event)
        @events << event
      end

      def last
        @events.last
      end

      def steps
        @events.select { |event| ![:setup, :teardown].include?(event.event) }
      end

      def status
        return :passed if @events.all?(&:passed?)
        return :failed if @events.any?(&:failed?)
      end
    end

    include Observable

    attr_reader :log

    def initialize
      @log = EventLog.new
      @results = []
    end

    def record(event)
      @log.add(event)
      case event.event
      when :setup
        @result = Result.new(event.arguments[0])
      when :teardown
        @results.push(@result)
        @result = nil
      else
        @result.record(event)
      end
    end

    def test_cases
      @log.select do |event|
        event.event == :setup
      end.map do |setup|
        setup.arguments
      end.flatten
    end

    def result_for(id)
      @results.find { |res| res.id == id }.status
    end

    def events
      @log.events
    end

    def record_run
      changed
      notify_observers(:start_run)
      yield
      changed
      notify_observers(:end_run)
    end

    def broadcast(result)
      record(result)
      changed
      notify_observers(:event) if result.important?
    end

    def broadcast_skip(instruction)
      if instruction.name == :dispatch
        broadcast(Model::Result.new(instruction, :skipped, "n/a"))
      end
    end

    def last_status
      @result.last
    end

    def summary
      @results
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
