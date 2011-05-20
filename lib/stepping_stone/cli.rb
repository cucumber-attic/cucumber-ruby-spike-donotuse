require 'kerplutz'

module SteppingStone
  module Cli
    def self.go!(args)
      case parse(args)[0]
      when :sst
        puts "sst"
      when :exec
        puts "sst exec"
        # add sst/sst_helper to load path
        # require every file in sst/lib
        # Create a parser
        # parser feature file, get test_case out
        # server = RbServer.new
        # formatter = ProgressFormatter.new
        # test_case = TestCase.new(server, formatter)
        # test_case.execute!
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
  end
end
