Given /^a passing scenario "(.+)" with:$/ do |name, body|
  @test_case = compile_scenario(name, body)
  define_mapper(sut)
end

Given /^these passing hooks:$/ do |hooks|
  hooks.rows.each do |aspect, subject|
    add_hook(aspect, subject)
  end
end

Given "there are no hooks" do
  # no-op
end

When /^Cucumber executes the scenario "(.+)"$/ do |name|
  execute(@test_case)
end

Then /^the life cycle events are:$/ do |table|
  table.map_column!(:event) { |event| event.to_sym }
  life_cycle_events.should eq(table.rows)
end

module CucumberWorld
  def compile_scenario(name, body)
    if test_cases = SteppingStone::GherkinCompiler.new.compile("Feature: test\nScenario: #{name}\n" << body)
      test_cases[0]
    else
      raise "Something when wrong while compiling #{body}"
    end
  end

  def define_mapper(sut)
    Module.new do
      extend sut.dsl_module
      include RSpec::Matchers

      def_map "I add 4 and 5" => :add
      def_map "the result is 9" => :assert_result

      def add
        @result = 5 + 4
      end

      def assert_result
        @result.should eq(9)
      end
    end
  end

  def add_hook(aspect, subject)
    hook_signature = [aspect.to_sym, subject.tr(' ', '_').to_sym]
    hook = SteppingStone::TextMapper::Hook.new(hook_signature) { |test_case| test_case.name }
    sut.add_hook(hook)
  end

  def sut
    @sut ||= SteppingStone::RbServer.new
  end

  def reporter
    @reporter ||= SteppingStone::Reporter.new(sut)
  end

  def executor
    @executor ||= SteppingStone::Model::Executor.new(reporter)
  end

  def execute(test_case)
    executor.execute(test_case)
  end

  def life_cycle_events
    reporter.events
  end
end

World(CucumberWorld)
