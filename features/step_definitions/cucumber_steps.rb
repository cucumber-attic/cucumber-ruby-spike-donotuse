Given /^a passing scenario "([^"]*)" with:$/ do |name, body|
  @scenario = SteppingStone::GherkinCompiler.new.compile("Feature: test\nScenario: #{name}\n" << body)[0]
  @namespace = SteppingStone::TextMapper::Namespace.new
  @namespace.add_mapper(SteppingStone::TextMapper::Mapping.new("I add 4 and 5", [:add]))
  @namespace.add_mapper(SteppingStone::TextMapper::Mapping.new("the result is 9", [:assert_result]))
end

Given /^these passing hooks:$/ do |hooks|
  @hooks = hooks.rows.collect do |aspect, subject|
    hook_signature = [aspect.to_sym, subject.tr(' ', '_').to_sym]
    SteppingStone::TextMapper::Hook.new(hook_signature) do |test_case|
      test_case.name
    end
  end
end

When /^Cucumber executes the scenario "([^"]*)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^the life cycle events are:$/ do |table|
  # table is a Cucumber::Ast::Table
  pending # express the regexp above with the code you wish you had
end

