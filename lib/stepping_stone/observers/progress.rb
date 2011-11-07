module SteppingStone
  module Observers
    class Progress
      def initialize(reporter, output)
        reporter.add_observer(self)
        @reporter = reporter
        @output = output
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
        scenario_count, scenarios_passed, scenarios_failed, scenarios_undefined =
          summary[:test_cases].values_at(:total, :passed, :failed, :undefined)
        step_count, steps_passed, steps_failed, steps_undefined = 
          summary[:instructions].values_at(:total, :passed, :failed, :undefined)

        @output.print "\n\n"
        @output.print "#{scenario_count} #{scenario_count == 1 ? "scenario" : "scenarios"}"
        @output.print " (#{scenarios_passed} passed)" if scenarios_passed > 0
        @output.print " (#{scenarios_failed} failed)" if scenarios_failed > 0
        @output.print " (#{scenarios_undefined} undefined)" if scenarios_undefined > 0
        @output.puts
        @output.print "#{step_count} #{step_count == 1 ? "step" : "steps"}" 
        @output.print " (#{steps_passed} passed)" if steps_passed > 0
        @output.print " (#{steps_failed} failed)" if steps_failed > 0
        @output.print " (#{steps_undefined} undefined)" if steps_undefined > 0
        @output.puts
      end
    end
  end
end
