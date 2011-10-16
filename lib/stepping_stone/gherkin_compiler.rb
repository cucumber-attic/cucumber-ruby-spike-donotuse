require 'gherkin'
require 'stepping_stone/model/test_case'
require 'stepping_stone/model/doc_string'
require 'stepping_stone/model/data_table'

module SteppingStone
  class Builder
    attr_reader :test_cases

    def initialize
      @pre_instructions = []
      @tc_instructions = []
      @current = nil
      @test_cases = []
    end

    def record(uri, tags)
      @current = uri
      @current_tags = tags
    end

    def replay
      if @current
        instructions = @pre_instructions.dup + @tc_instructions
        test_case = Model::TestCase.new(@current, *instructions)
        test_case.tags = @current_tags
        @test_cases.push(test_case)
        @tc_instructions = []
        @current = nil
        @current_tags = nil
      end
    end

    def add_instruction(parts)
      if @current
        @tc_instructions.push(parts)
      else
        @pre_instructions.push(parts)
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
      instruction = [step.name]
      instruction << Model::DocString.new(step.doc_string.value) if step.doc_string
      instruction << Model::DataTable.new(step.rows.map { |row| row.cells }) if step.rows
      @builder.add_instruction(instruction)
    end

    def eof
      @builder.replay
    end

    def method_missing(name, *args, &blk)
      #puts "name: #{name}, args: #{args}"
    end
  end
end
