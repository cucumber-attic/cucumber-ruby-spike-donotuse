require 'gherkin'
require 'stepping_stone/model/test_case'
require 'stepping_stone/model/doc_string'
require 'stepping_stone/model/data_table'

module SteppingStone
  class Builder
    attr_reader :test_cases

    def initialize
      @pre_actions = []
      @tc_actions = []
      @current = nil
      @test_cases = []
    end

    def record(uri, tags)
      @current = uri
      @current_tags = tags
    end

    def replay
      if @current
        actions = @pre_actions.dup + @tc_actions
        test_case = Model::TestCase.new(@current, *actions)
        test_case.tags = @current_tags
        @test_cases.push(test_case)
        @tc_actions = []
        @current = nil
        @current_tags = nil
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

  class GherkinCompiler
    def initialize(builder = Builder.new)
      @parser = ::Gherkin::Parser::Parser.new(self, true, "root", false)
      @builder = builder
    end

    def compile(content)
      uri_location = ""
      line_offset = 0
      @parser.parse(content, uri_location, line_offset)
      @builder.test_cases
    end

    def scenario(scenario)
      @builder.replay
      @builder.record(scenario.name, scenario.tags.collect(&:name))
    end

    def step(step)
      action = [step.name]
      action << Model::DocString.new(step.doc_string.value) if step.doc_string
      action << Model::DataTable.new(step.rows.map { |row| row.cells }) if step.rows
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
