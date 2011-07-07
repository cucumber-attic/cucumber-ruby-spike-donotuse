Given /^a passing scenario "(.+)" with:$/ do |name, body|
  @test_case = SteppingStone::GherkinCompiler.new.compile("Feature: test\nScenario: #{name}\n" << body)[0]

  class FakeSut
    attr_reader :mappings, :hooks, :helpers

    def initialize
      @mappings = []
      @hooks = []
      @helpers = Module.new do
        def add
          @result = 5 + 4
        end

        def assert_result
          @result.should eq(9)
        end
      end
    end

    def add_mapping(from, to)
      mappings << SteppingStone::TextMapper::Mapping.new(from, to)
    end

    def add_hook(signature, &blk)
      hooks << SteppingStone::TextMapper::Hook.new(signature, &blk)
    end

    def find_mapping(from)
      mappings.find { |mapping| mapping.match(from) } or raise(SteppingStone::TextMapper::Namespace::UndefinedMappingError.new(from))
    end

    def find_hook(from)
      hooks.find { |hook| hook.match(from) }
    end

    def start_test(test_case)
      @context = SteppingStone::TextMapper::Context.new(self, [RSpec::Matchers, helpers])
      @context.setup(test_case)
    end

    def end_test(test_case)
      @context.teardown(test_case)
    end

    def dispatch(action)
      @context.dispatch(action)
    end
  end

  @sut = FakeSut.new
  @sut.add_mapping("I add 4 and 5", :add)
  @sut.add_mapping("the result is 9", :assert_result)
end

Given /^these passing hooks:$/ do |hooks|
  hooks.rows.each do |aspect, subject|
    hook_signature = [aspect.to_sym, subject.tr(' ', '_').to_sym]
    @sut.add_hook(hook_signature) { |test_case| test_case.name }
  end
end

When /^Cucumber executes the scenario "(.+)"$/ do |name|
  executor = SteppingStone::Model::Executor.new(@sut)
  executor.execute(@test_case)
  @events = executor.events
end

Then /^the life cycle events are:$/ do |table|
  table.map_column!(:event) { |event| event.to_sym }
  @events.should eq(table.rows)
end

