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

Given "I'm using the progress formatter" do
  start_progress_formatter
end

Then "the scenario passes" do
  reporter.should be_passed
end

Then "the scenario fails" do
  reporter.should be_failed
end

Then "the scenario is pending" do
  reporter.should be_pending
end

Then "the scenario is undefined" do
  reporter.should be_undefined
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
  add_hook(:setup) { @before_time = ->{ DateTime.now }.call }
end

Given /^a passing after hook$/ do
  add_hook(:teardown) { @after_time = ->{ DateTime.now }.call }
end

Given /^a passing around hook$/ do
  add_hook(:around) do |continuation, session|
    session.set_attribute(:around_pre_time, ->{ DateTime.now }.call)
    continuation.call
    session.set_attribute(:around_post_time, -> { DateTime.now }.call)
  end
end

Given /^a hook tagged with "(.+)"$/ do |tag|
  add_hook(:setup) { @before_time = -> { DateTime.now }.call }
end

Given /^an untagged hook$/ do
  add_hook(:setup) { @before_time = -> { DateTime.now }.call }
end

Then /^the before hook is fired before the scenario$/ do
  session.value_of(:before_time).should be < test_case_start_time
end

Then /^the after hook is fired after the scenario$/ do
  session.value_of(:after_time).should be > test_case_start_time
end

Then /^the around hook fires around the scenario$/ do
  session.value_of(:around_pre_time).should be < test_case_start_time
  session.value_of(:around_post_time).should be > test_case_end_time
end

Then /^the around hook is fired around the other hooks$/ do
  session.values_of(:around_pre_time, :before_time, :after_time, :around_post_time).should
    eq(session.values_of(:around_pre_time, :around_post_time, :before_time, :after_time).sort)
end

Then /^the hook is fired$/ do
  session.value_of(:before_time).should_not be_nil
end

Then /^the hook is not fired$/ do
  session.value_of(:before_time).should_not be_nil
end

When /^Cucumber executes the scenario "(.+)"$/ do |name|
  execute(@test_case)
end

When "Cucumber executes a scenario" do
  body = "Given a passing step"
  @test_case = compile_scenario("Test Scenario", body)
  create_passing_mappings(body)
  execute(@test_case)
end

When /^Cucumber executes a scenario tagged with "(.+)"$/ do |tag|
  body = "Given a passing step"
  create_passing_mappings(body)
  @test_case = compile_scenario("Test Scenario", body, background=nil, tags=tag)
  execute(@test_case)
end

When /^Cucumber executes a scenario with no tags$/ do
  body = "Given a passing step"
  create_passing_mappings(body)
  @test_case = compile_scenario("Test Scenario", body, background=nil, tags=[])
  execute(@test_case)
end

Then /^the life cycle history is:$/ do |table|
  table.map_column!(:event, &:to_sym)
  table.map_column!(:status, &:to_sym)
  table.map_column!(:name) { |name| [name] }
  life_cycle_history.should eq(table.rows)
end

Then "the progress output looks like:" do |output|
  progress_output.should eq(output)
end

module CucumberWorld
  def compile_scenario(name, body, background=nil, tags=nil)
    feature = build_feature(name, body, background, tags)
    if test_cases = SteppingStone::GherkinCompiler.new.compile(feature)
      test_cases[0]
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
    listener = ::TextMapper::BlockMapping.new([event.to_sym, filter]) { |test_case| result }
    sut.add_mapping(listener)
  end

  def add_mapping(from, to)
    mapping = ::TextMapper::Mapping.from_primitives(from.unshift(:map), to)
    sut.add_mapping(mapping)
  end

  def add_hook(event, *exprs, &hook)
    if event == :around
      sut.add_around_hook(*exprs, &hook)
    else
      hook = SteppingStone::Servers::TextMapper::HookMapping.new(event, *exprs, &hook)
      sut.add_mapping(hook)
    end
  end

  def sut
    @sut ||= SteppingStone::Servers::TextMapper.new
  end

  def reporter
    @reporter ||= SteppingStone::Reporter.new
  end

  def runner
    @runner ||= SteppingStone::Runner.new(sut, reporter)
  end

  def session
    runner.current_session
  end

  def progress_output
    @progress.string
  end

  def execute(test_case)
    reporter.record_run { runner.execute(test_case) }
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

  def start_progress_formatter
    @progress = StringIO.new
    SteppingStone::Observers::Progress.new(reporter, @progress)
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

  def global_opts
    SteppingStone.configuration.global_opts
  end
end

Before do
  define_context_mixins
end

World(CucumberWorld)
