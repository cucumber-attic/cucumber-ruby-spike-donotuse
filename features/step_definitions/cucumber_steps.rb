Given /^a scenario "(.+)" with:$/ do |name, body|
  feature.add_scenario(body, name)
end

Given "a scenario with:" do |body|
  feature.add_scenario(body)
end

Given /^a passing scenario "(.+)" with:$/ do |name, body|
  feature.add_scenario(body, name)
  create_passing_mappings(feature.steps_text)
end

Given "a passing scenario with:" do |body|
  feature.add_scenario(body)
  create_passing_mappings(body)
end

Given "a passing background with:" do |background|
  feature.background = background
  create_passing_mappings(background)
end

Given "a background with:" do |background|
  feature.background = background
end

When "Cucumber executes the scenario" do
  execute_cucumber
end

When "Cucumber executes a scenario" do
  feature.add_default_scenario
  create_passing_mappings(feature.steps_text)
  execute_cucumber
end

When /^Cucumber executes a scenario tagged with "(.+)"$/ do |tag|
  feature.add_default_scenario
  feature.tags = tag
  create_passing_mappings(feature.steps_text)
  execute_cucumber
end

When /^Cucumber executes a scenario with no tags$/ do
  feature.add_default_scenario
  feature.tags = []
  create_passing_mappings(feature.steps_text)
  execute_cucumber
end

Given "all of the steps in the scenario pass" do
  create_passing_mappings(feature.steps_text)
end

Given "all of the steps in the scenario fail" do
  create_failing_mappings(feature.steps_text)
end

Given "all of the steps in the scenario are undefined" do
  create_undefined_mappings(feature.steps_text)
end

Given /^the step "(.+)" has a (\w+) mapping$/ do |name, status|
  add_method_mapping([name], ["do_#{status}".to_sym])
end

Given "the progress formatter is observing execution" do
  start_progress_formatter
end

Then "the scenario passes" do
  last_scenario_status.should be(:passed)
end

Then "the scenario fails" do
  last_scenario_status.should be(:failed)
end

Then "the scenario is pending" do
  last_scenario_status.should be(:pending)
end

Then "the scenario is undefined" do
  last_scenario_status.should be(:undefined)
end

Then /^the step "(.+)" is skipped$/ do |name|
  skipped = @event_log.history.find { |ev| ev.arguments == [name] }
  skipped.should be_skipped
end

Given /^a passing (\w+) mapping$/ do |event|
  add_mapping(event)
end

Given /^a failing (\w+) mapping$/ do |event|
  add_failing_mapping(event)
end

Given /^a (\w+) mapping that passes with "(.+)"$/ do |event, result|
  add_mapping(event, result)
end

Given "there are no setup or teardown mappings" do
  sut.mappings.select do |mapping|
    mapping.match([:setup, Object]) or mapping.match([:teardown, Object])
  end.should be_empty
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

Then /^the life cycle history is:$/ do |table|
  table.map_column!(:event, &:to_sym)
  table.map_column!(:status, &:to_sym)
  life_cycle_history.should eq(table.rows)
end

Then "the progress output looks like:" do |output|
  progress_output.should eq(output)
end

module CucumberWorld
  def feature
    @feature ||= FeatureBuilder.new
  end

  def compile(gherkin)
    SteppingStone::GherkinCompiler.new.compile(gherkin)
  end

  def execute_cucumber
    execute(compile(feature.build).first)
  end

  def execute(test_case)
    reporter.record_run { runner.execute(test_case) }
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

  def add_mapping(event, result = "passed", filter = Object)
    mapping = ::TextMapper::BlockMapping.new([event.to_sym, filter]) { |test_case| result }
    sut.add_mapping(mapping)
  end

  def add_failing_mapping(event, filter = Object)
    mapping = ::TextMapper::BlockMapping.new([event.to_sym, filter]) { |text_case| true.should eq(false) }
    sut.add_mapping(mapping)
  end

  def add_method_mapping(from, to)
    mapping = ::TextMapper::MethodMapping.from_primitives(from.unshift(:dispatch), to)
    sut.add_mapping(mapping)
  end

  def add_hook(event, *exprs, &hook)
    if event == :around
      sut.add_wrapper(*exprs, &hook)
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

  def last_scenario_status
    reporter.status_of(FeatureBuilder::DEFAULT_SCENARIO_NAME)
  end

  def start_event_log
    @event_log ||= SteppingStone::Observers::EventLog.new(reporter)
  end

  def life_cycle_history
    @event_log.history.inject([]) do |memo, e|
      if e.value.is_a?(Hash) and !e.value.empty?
        e.value.values.each do |v|
          memo << [e.name, e.status]
        end
      else
        memo << [e.name, e.status]
      end
      memo
    end
  end

  def test_case_start_time
    @event_log.history.first.created_at
  end

  def test_case_end_time
    @event_log.history.last.created_at
  end

  def start_progress_formatter
    @progress = StringIO.new
    SteppingStone::Observers::Progress.new(reporter, @progress)
  end

  def create_passing_mappings(steps_text)
    create_mappings(steps_text, :do_passing)
  end

  def create_failing_mappings(steps_text)
    create_mappings(steps_text, :do_failing)
  end

  def create_undefined_mappings(steps_text)
    # no-op
  end

  def create_mappings(steps_text, target)
    steps_text.split("\n").each do |line|
      from = line.gsub(/(Given|When|Then|But|And)\s/, '')
      add_method_mapping([from], [target])
    end
  end

  def global_opts
    SteppingStone.configuration.global_opts
  end
end

Before do
  define_context_mixins
  start_event_log
end

World(CucumberWorld)
