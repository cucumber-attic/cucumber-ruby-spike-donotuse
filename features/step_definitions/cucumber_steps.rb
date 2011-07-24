Given /^a passing scenario "(.+)" with:$/ do |name, body|
  @test_case = SteppingStone::GherkinCompiler.new.compile("Feature: test\nScenario: #{name}\n" << body)[0]
  sut = SteppingStone::RbServer.new

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

  @sut = sut
end

Given /^these passing hooks:$/ do |hooks|
  hooks.rows.each do |aspect, subject|
    hook_signature = [aspect.to_sym, subject.tr(' ', '_').to_sym]
    hook = SteppingStone::TextMapper::Hook.new(hook_signature) { |test_case| test_case.name }
    @sut.mapper_namespace.add_hook(hook)
  end
end

Given "there are no hooks" do
  # no-op
end

When /^Cucumber executes the scenario "(.+)"$/ do |name|
  reporter = SteppingStone::Reporter.new(@sut)
  executor = SteppingStone::Model::Executor.new(reporter)
  executor.execute(@test_case)
  @events = reporter.events
end

Then /^the life cycle events are:$/ do |table|
  table.map_column!(:event) { |event| event.to_sym }
  @events.should eq(table.rows)
end

