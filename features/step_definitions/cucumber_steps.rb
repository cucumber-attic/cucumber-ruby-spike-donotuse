Given /^a passing scenario "(.+)" with:$/ do |name, body|
  @test_case = compile_scenario(name, body, @background)
end

Given /^a passing background with:$/ do |background|
  @background = background
end

Given /^these passing hooks:$/ do |hooks|
  hooks.rows.each do |aspect, subject|
    add_hook(aspect, subject, :pass)
  end
end

Given "there are no hooks" do
  sut.hooks.should be_empty
end

Given /^a passing before hook$/ do
  env_hooks.before { @before_time = -> { DateTime.now }.call }
end

Given /^a passing after hook$/ do
  env_hooks.after { @after_time = -> { DateTime.now }.call }
end

Given /^a passing around hook$/ do
  env_hooks.around do |execution|
    @around_pre_time = -> { DateTime.now }.call
    execution.call
    @around_post_time = -> { DateTime.now }.call
  end
end

When /^Cucumber executes the scenario "(.+)"$/ do |name|
  execute(@test_case)
end

When "Cucumber executes a scenario" do
  @test_case = compile_scenario("Test Scenario", "Given a passing step")
  execute(@test_case)
end

Then /^the life cycle history is:$/ do |table|
  table.map_column!(:event, &:to_sym)
  table.map_column!(:status, &:to_sym)
  table.map_column!(:name) { |name| [name] }
  life_cycle_history.should eq(table.rows)
end

Then /^the before hook is fired before the scenario$/ do
  @before_time.should be < test_case_start_time
end

Then /^the after hook is fired after the scenario$/ do
  @after_time.should be > test_case_end_time
end

Then /^the around hook fires around the scenario$/ do
  @around_pre_time.should be < test_case_start_time
  @around_post_time.should be > test_case_end_time
end

module CucumberWorld
  def compile_scenario(name, body, background=nil)
    feature = build_feature(name, body, background)
    if test_cases = SteppingStone::GherkinCompiler.new.compile(feature)
      test_cases[0]
    else
      raise "Something when wrong while compiling #{body}"
    end
  end

  def build_feature(name, body, background=nil)
    out = "Feature: test\n"
    out << "Background:\n #{background}\n" if background
    out << "Scenario: #{name}\n#{body}"
  end

  def define_mapper(sut)
    Module.new do
      extend sut.dsl_module
      include RSpec::Matchers

      def_map /I log in as "(\w+)"/ => :login_as
      def_map "I add 4 and 5" => :add
      def_map "the result is 9" => :assert_result
      def_map "a passing step" => :passing

      def login_as(userid)
        @userid = userid
      end

      def add
        @result = 5 + 4
      end

      def assert_result
        @result.should eq(9)
      end

      def passing
        @passing = true
      end
    end
  end

  def add_hook(aspect, subject, result)
    # subject isn't used for anything yet
    hook = SteppingStone::TextMapper::Hook.new([aspect.to_sym, {}]) { |test_case| result }
    sut.add_mapping(hook)
  end

  def env_hooks
    @env_hooks ||= SteppingStone::HookList.new
  end

  def sut
    @sut ||= SteppingStone::Servers::Rb.new(env_hooks)
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

  def life_cycle_history
    reporter.history.map(&:to_a)
  end

  def test_case_start_time
    reporter.history.first.created_at
  end

  def test_case_end_time
    reporter.history.last.created_at
  end
end

Before do
  define_mapper(sut)
end

World(CucumberWorld)
