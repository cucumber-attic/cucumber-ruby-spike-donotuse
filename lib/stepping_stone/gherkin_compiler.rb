require 'gherkin'

require 'stepping_stone/model/test_case'

module SteppingStone
  class GherkinCompiler
    def initialize
      @parser = ::Gherkin::Parser::Parser.new(self, true, "root", false)
    end

    def compile(content)
      uri_location = ""
      line_offset = 0
      @parser.parse(content, uri_location, line_offset)
      @test_case
    end

    def step(step)
      @actions ||= []
      action = [step.name]
      action << step.multiline_arg.value if step.multiline_arg
      @actions << action
    end

    def eof
      @test_case = Model::TestCase.new(*@actions)
    end

    def method_missing(name, *args, &blk)
      #puts "name: #{name}, args: #{args}"
    end
  end
end
