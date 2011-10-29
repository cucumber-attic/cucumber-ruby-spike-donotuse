require 'kerplutz'

require 'stepping_stone'
require 'stepping_stone/gherkin_compiler'
require 'stepping_stone/reporter'
require 'stepping_stone/runner'

module SteppingStone
  module Cli
    def self.go!(args)
      cmd, _arguments, remainder = parse(args)

      case cmd
      when :exec
        Exec.execute(remainder)
      end
    end

    def self.parse(args)
      Kerplutz.build(:cuke) do |base|
        base.banner = "Usage: #{base.name} [OPTIONS] COMMAND [ARGS]"

        base.action :version, "Show the version", abbrev: :V do
          puts "Cucumber v#{SteppingStone::VERSION}"
        end

        base.command :exec, "Execute a specification" do |cmd|
        end
      end.parse(args)
    end

    class Exec
      def self.execute(features)
        new(features).execute
      end

      def initialize(locations)
        @locations = locations
      end

      def execute
        # Should be part of boot process
        require 'stepping_stone/code_loader'
        CodeLoader.add_to_load_path('.', 'cukes')
        require 'cukes/cukes_helper'

        compiler = GherkinCompiler.new

        # Do this properly: no need to flatten
        test_cases = @locations.collect do |location|
          content = File.read(location)
          compiler.compile(content)
        end.flatten

        server = Servers.boot!(:default)
        reporter = Reporter.new
        runner = Runner.new(server, reporter)

        reporter.record_run do
          test_cases.each do |test_case|
            runner.execute(test_case)
          end
        end

        require 'stringio'
        out = StringIO.new
        reporter.write(out)
        puts out.string
      end
    end
  end
end
