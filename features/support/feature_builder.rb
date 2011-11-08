class FeatureBuilder
  DEFAULT_FEATURE_NAME  = "Test Feature"
  DEFAULT_SCENARIO_NAME = "Test scenario"
  DEFAULT_SCENARIO_BODY = "Given a passing step"

  attr_reader :scenarios

  def initialize(name = DEFAULT_FEATURE_NAME)
    @name = name
    @scenarios = []
  end

  def background=(background)
    @background = background
  end

  def tags=(tags)
    @tags = tags
  end

  def add_scenario(body, name = DEFAULT_SCENARIO_NAME)
    @scenarios.push([name, body])
  end

  def add_default_scenario
    @scenarios.push([DEFAULT_SCENARIO_NAME, DEFAULT_SCENARIO_BODY])
  end

  def steps_text
    String.new.tap do |output|
      output << @background if @background
      @scenarios.inject(output) { |out, (_, body)| out << body }
    end
  end

  def build
    String.new.tap do |output|
      build_header(output)
      build_background(output)
      build_scenarios(output)
    end
  end

  def build_header(str)
    str << "Feature: #{@name}\n"
  end

  def build_background(str)
    str << "Background:\n#{@background}\n" if @background
  end

  def build_scenarios(str)
    @scenarios.inject(str) do |text, (name, body)|
      text << "#{@tags}\n" if @tags
      text << "Scenario: #{name}\n#{body}"
    end
  end
end

