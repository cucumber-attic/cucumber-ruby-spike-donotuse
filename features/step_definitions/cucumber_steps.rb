Given /^a passing scenario "(.+)" with:$/ do |name, body|
  @test_case = SteppingStone::GherkinCompiler.new.compile("Feature: test\nScenario: #{name}\n" << body)[0]
  @namespace = SteppingStone::TextMapper::Namespace.new
  @namespace.add_mapping(SteppingStone::TextMapper::Mapping.new("I add 4 and 5", :add))
  @namespace.add_mapping(SteppingStone::TextMapper::Mapping.new("the result is 9", :assert_result))
  calculator_mod = Module.new do
    include RSpec::Matchers # should be a way to add this module into context automagically

    def add
      @result = 4 + 5
    end

    def assert_result
      @result.should eq(9)
    end
  end
  @namespace.add_mapper(calculator_mod)
end

Given /^these passing hooks:$/ do |hooks|
  hooks.rows.each do |aspect, subject|
    hook_signature = [aspect.to_sym, subject.tr(' ', '_').to_sym]
    @namespace.add_hook(SteppingStone::TextMapper::Hook.new(hook_signature) { |test_case| test_case.name })
  end
end

When /^Cucumber executes the scenario "(.+)"$/ do |name|
  context = @namespace.build_context
  @test_case.each do |action|
    context.dispatch(action)
  end
end

Then /^the life cycle events are:$/ do |table|
  # table is a Cucumber::Ast::Table
  pending # express the regexp above with the code you wish you had
end

