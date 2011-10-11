Given /^a scenario "(.+)" with:$/ do |name, body|
  @test_case = compile_scenario(name, body)
end

Given /^a passing scenario "(.+)" with:$/ do |name, body|
  @test_case = compile_scenario(name, body, @background)
  create_passing_mappings(body)
end

Given "a passing background with:" do |background|
  @background = background
  create_passing_mappings(background)
end

Given /^the step "(.+)" has a (\w+) mapping$/ do |name, status|
  add_mapping([name], ["do_#{status}".to_sym])
end

Then "the scenario passes" do
  passed = reporter.history.all?(&:passed?)
  passed.should be(true)
end

Then "the scenario fails" do
  failed = reporter.history.any?(&:failed?)
  failed.should be(true)
end

Then "the scenario is pending" do
  pending = reporter.history.any?(&:pending?)
  pending.should be(true)
end

Then "the scenario is undefined" do
  undefined = reporter.history.any?(&:undefined?)
  undefined.should be(true)
end

Then /^the step "(.+)" is skipped$/ do |name|
  skipped = reporter.history.find { |ev| ev.arguments == [name] }
  skipped.should be_skipped
end

Given /^these passing listeners:$/ do |listeners|
  listeners.rows.each do |event, _filter|
    add_listener(event)
  end
end

Given "there are no listeners" do
  sut.listeners.should be_empty
end

Given /^a passing before hook$/ do
  hooks.add(:before) { @before_time = -> { DateTime.now }.call }
end

Given /^a passing after hook$/ do
  hooks.add(:after) { @after_time = -> { DateTime.now }.call }
end

Given /^a passing around hook$/ do
  hooks.add(:around) do |execution|
    @around_pre_time = -> { DateTime.now }.call
    execution.call
    @around_post_time = -> { DateTime.now }.call
  end
end

Given /^a hook tagged with "(.+)"$/ do |tag|
  hooks.add(:before, tag) { @before_time = -> { DateTime.now }.call }
end

Given /^an untagged hook$/ do
  hooks.add(:before) { @before_time = -> { DateTime.now }.call }
end

When /^Cucumber executes the scenario "(.+)"$/ do |name|
  execute(@test_case)
end

When "Cucumber executes a scenario" do
  @test_case = compile_scenario("Test Scenario", "Given a passing step")
  execute(@test_case)
end

When /^Cucumber executes a scenario tagged with "(.+)"$/ do |tag|
  @test_case = compile_scenario("Test Scenario", "Given a passing step", background=nil, tags=tag)
  execute(@test_case)
end

When /^Cucumber executes a scenario with no tags$/ do
  @test_case = compile_scenario("Test Scenario", "Given a passing step", background=nil, tags=[])
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

Then /^the around hook is fired around the other hooks$/ do
  chronological = [@around_pre_time, @around_post_time, @before_time, @after_time].sort
  chronological.should eq([@around_pre_time, @before_time, @after_time, @around_post_time])
end

Then /^the hook is fired$/ do
  defined?(@before_time).should eq("instance-variable")
end

Then /^the hook is not fired$/ do
  defined?(@before_time).should eq(nil)
end

module CucumberWorld
  def compile_scenario(name, body, background=nil, tags=nil)
    feature = build_feature(name, body, background, tags)
    if test_cases = SteppingStone::GherkinCompiler.new.compile(feature)
      create_script(test_cases[0])
    else
      raise "Something when wrong while compiling #{body}"
    end
  end

  def build_feature(name, body, background=nil, tags=nil)
    out = "Feature: test\n"
    out << "Background:\n #{background}\n" if background
    out << "\n"
    out << "#{tags}\n" if tags
    out << "Scenario: #{name}\n#{body}"
  end

  def define_context_mixins
    add_mixin do
      def do_passing
        @passing = true
      end

      def do_failing
        1.should eq(2)
      end

      def do_pending
        pending("This is pending!")
      end
    end

    add_mixin(RSpec::Matchers)
  end

  def add_mixin(mixin=nil, &block)
    if block_given?
      sut.add_mixin(Module.new(&block))
    else
      sut.add_mixin(mixin)
    end
  end

  def add_listener(event, filter = nil, result = :pass)
    listener = ::TextMapper::Listener.new([event.to_sym, filter]) { |test_case| result }
    sut.add_mapping(listener)
  end

  def add_mapping(from, to)
    mapping = ::TextMapper::Mapping.from_primitives(from.unshift(:map), to)
    sut.add_mapping(mapping)
  end

  def hooks
    @hooks ||= SteppingStone::Hooks.new
  end

  def sut
    @sut ||= SteppingStone::Servers::TextMapper.new(hooks)
  end

  def reporter
    @reporter ||= SteppingStone::Reporter.new(executor)
  end

  def executor
    @executor ||= SteppingStone::Executor.new(sut)
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

  def start_reporter
    reporter
  end

  def create_script(test_case)
    SteppingStone::Model::Script.new(test_case)
  end

  def create_passing_mappings(steps_text)
    create_mappings(steps_text, :do_passing)
  end

  def create_mappings(steps_text, target)
    steps_text.split("\n").each do |line|
      from = line.gsub(/(Given|When|Then|But|And)\s/, '')
      add_mapping([from], [target])
    end
  end
end

Before do
  define_context_mixins
  start_reporter
end

World(CucumberWorld)
