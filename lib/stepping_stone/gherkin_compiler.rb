require 'gherkin'

require 'stepping_stone/model/test_case'

module SteppingStone
  class Action
    attr_reader :elements

    def initialize(*elements)
      @elements = elements.collect(&:freeze)
      @elements.freeze
    end

    def to_a
      elements
    end

    def to_s
      elements.join
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
      elements = [step.name, step.multiline_arg].compact
      @actions << Action.new(*elements)
    end

    def eof
      @test_case = SteppingStone::TestCase.new(*@actions)
    end

    def method_missing(name, *args, &blk)
      #puts "name: #{name}, args: #{args}"
    end
  end
end
