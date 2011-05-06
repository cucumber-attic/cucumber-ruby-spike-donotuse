require 'optparse'

module SteppingStone
  module Cli
    class ExecParser
      def self.parse(args)
        new(args).parse
      end

      def initialize(args)
        @args = args
      end

      def parse
        OptionParser.new do |parser|
          parser.on('-v', '--v', 'Verbose') do
            puts "Verbose!"
          end
        end.parse!(@args)
      end
    end

    def self.go!(args)
      # parse options from args
      parse_command(args)

      # add sst/sst_helper to load path
      # require every file in sst/lib
      # Create a parser
      # parser feature file, get test_case out
      # server = RbServer.new
      # formatter = ProgressFormatter.new
      # test_case = TestCase.new(server, formatter)
      # test_case.execute!
    end

    def self.parse_command(args)
      case args.shift
      when "x", "exec"
        ExecParser.parse(args)
      when "-h", "--help"

        print <<-EOH
Usage: sst [command] [options] [input source]

 Commands:
  x, exec  Execute input from a file or directory

 For command-specific options, type: sst [command] -h
        EOH

      else
        print "For help, type: sst -h\n"
      end
    end

    def self.print_help
    end
  end
end
