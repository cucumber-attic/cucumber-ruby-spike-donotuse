require 'gherkin'
require 'stepping_stone/model/test_case'
require 'stepping_stone/model/doc_string'

module SteppingStone
  class GherkinCompiler
    class Builder
      attr_reader :test_cases

      def initialize
        @pre_actions = []
        @tc_actions = []
        @current = nil
        @test_cases = []
      end

      def record(uri)
        @current = uri
      end

      def replay
        if @current
          actions = @pre_actions.dup + @tc_actions
          @test_cases.push(Model::TestCase.new(*actions))
          @tc_actions = []
          @current = nil
        end
      end

      def add_action(parts)
        if @current
          @tc_actions.push(parts)
        else
          @pre_actions.push(parts)
        end
      end
    end

    def initialize
      @parser = ::Gherkin::Parser::Parser.new(self, true, "root", false)
      @builder = Builder.new
    end

    def compile(content)
      uri_location = ""
      line_offset = 0
      @parser.parse(content, uri_location, line_offset)
      @builder.test_cases
    end

    def scenario(scenario)
      @builder.replay
      @builder.record(scenario.name)
    end

    def step(step)
      action = [step.name]
      action << Model::DocString.new(step.multiline_arg.value) if step.multiline_arg
      @builder.add_action(action)
    end

    def eof
      @builder.replay
    end

    def method_missing(name, *args, &blk)
      #puts "name: #{name}, args: #{args}"
    end
  end
end
