require 'kerplutz'

require 'stepping_stone/gherkin_compiler'
require 'stepping_stone/results'

module SteppingStone
  module Cli
    def self.go!(args)
      cmd, _arguments, remainder = parse(args)

      case cmd
      when :sst
        raise "Doesn't do anything yet"
      when :exec
        Exec.execute(remainder)
      end
    end

    def self.parse(args)
      Kerplutz.build(:sst) do |base|
        base.banner = "Usage: #{base.name} [OPTIONS] COMMAND [ARGS]"

        base.action :version, "Show the version", abbrev: :V do
          puts "Stepping Stone v0.0.0"
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
        # add sst/sst_helper to load path
        # require every file in sst/mappers
        # Create a parser
        # parser feature file, get test_case out
        # server = RbServer.new
        # formatter = ProgressFormatter.new
        # test_case = TestCase.new(server, formatter)
        # test_case.execute!
        #
        # server = RbServer.new
        # formatter = ProgressFormatter.new
        # server.execute!(TestCase.new) do |result|
        #   formatter.output(result)
        # end

        require 'stepping_stone/rb_project'

        RbProject.add_to_load_path('.', 'sst')
        require 'sst/sst_helper'

        RbProject.require_glob("sst/mappers", "**/*")

        compiler = GherkinCompiler.new

        test_cases = @locations.collect do |location|
          content = File.read(location)
          compiler.compile(content)
        end

        results = Results.new
        server = RbServer.new(results)

        test_cases.each do |test_case|
          server.execute(test_case)
        end

        puts results.to_s
      end
    end
  end
end
