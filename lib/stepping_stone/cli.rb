require 'kerplutz'

module SteppingStone
  module Cli
    def self.go!(args)
      # add sst/sst_helper to load path
      # require every file in sst/lib
      # Create a parser
      # parser feature file, get test_case out
      # server = RbServer.new
      # formatter = ProgressFormatter.new
      # test_case = TestCase.new(server, formatter)
      # test_case.execute!
      results = Kerplutz.build(:sst) do |base|
        base.banner = "Usage: #{base.name} [OPTIONS] COMMAND [ARGS]"
        base.action :version, "Show the version", abbrev: :V do
          puts "Stepping Stone v0.0.0"
        end

        base.command :exec, "Execute a specification" do |cmd|
        end
      end.parse(args)

      case results[0]
      when "sst"
        puts "sst"
      when "exec"
        puts "sst exec"
      end
    end
  end
end
