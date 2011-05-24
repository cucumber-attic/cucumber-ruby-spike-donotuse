require 'gherkin'

require 'stepping_stone/test_case'
require 'stepping_stone/rb_server'

module SteppingStone
  class Action
    attr_reader :elements

    def initialize(*elements)
      @elements = elements.collect(&:freeze)
      @elements.freeze
    end
  end

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
      elements = [step.keyword, step.name, step.multiline_arg].compact
      @actions << Action.new(*elements)
    end

    def eof
      @test_case = SteppingStone::TestCase.new(RbServer.new, *@actions)
    end

    def method_missing(name, *args, &blk)
      #puts "name: #{name}, args: #{args}"
    end
  end
end
