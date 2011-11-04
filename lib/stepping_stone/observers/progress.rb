module SteppingStone
  module Observers
    class Progress
      def initialize(reporter, output)
        @reporter = reporter
        @output = output
        reporter.add_observer(self)
      end

      def update(type)
        case type
        when :event
          do_event
        when :end_run
          do_summary
        end
      end

      def do_event
        event = @reporter.last_status
        if event && event.response_required?
          letter = {
            :passed    => ".",
            :failed    => "F",
            :undefined => "U",
            :skipped   => "S",
            :pending   => "P"
          }[event.status]
          @output.print(letter)
        end
      end

      def do_summary
        summary = @reporter.summary
        scenario_count, scenarios_passed = summary[:test_cases].values_at(:total, :passed)
        step_count, steps_passed = summary[:instructions].values_at(:total, :passed)

        @output.print "\n\n"
        @output.puts "#{scenario_count} #{scenario_count == 1 ? "scenario" : "scenarios"} (#{scenarios_passed} passed)"
        @output.puts "#{step_count} #{step_count == 1 ? "step" : "steps"} (#{steps_passed} passed)"
      end
    end
  end
end
