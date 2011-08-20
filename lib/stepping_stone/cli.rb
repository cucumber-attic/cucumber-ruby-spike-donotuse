require 'kerplutz'

require 'stepping_stone'
require 'stepping_stone/gherkin_compiler'
require 'stepping_stone/reporter'
require 'stepping_stone/model/executor'

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
          puts "Stepping Stone v#{SteppingStone::VERSION}"
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
        CodeLoader.add_to_load_path('.', 'sst')
        require 'sst/sst_helper'

        compiler = GherkinCompiler.new

        # Do this properly: no need to flatten
        test_cases = @locations.collect do |location|
          content = File.read(location)
          compiler.compile(content)
        end.flatten

        server = Servers.boot!(:default)
        reporter = Reporter.new(server)
        executor = Model::Executor.new(reporter)

        test_cases.each do |test_case|
          executor.execute(test_case)
        end

        puts reporter.to_s
      end
    end
  end
end
