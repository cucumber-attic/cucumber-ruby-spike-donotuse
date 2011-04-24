Feature: CLI
  Scenario: Execution
    Given a file named "docs/calculator.feature" with:
      """
      Feature: Calculator
        Scenario: Addition
          Given a calculator
          When I press 5 + 4
          Then the result is 9

      """
    And a file named "lib/calculator/steps.rb" with:
      """
      require 'stepping_stone/cucumber'

      Given "a calculator" do
        @calculator = Calculator.new
      end

      When /^I add (\d+) to (\d+)$/ do |m, n|
        @calculator.add(m.to_i, n.to_i)
      end

      Then /^the result is (\d+)$/ do |result|
        @calculator.result.should == result.to_i
      end
      """
    When I successfully run `sst x docs/calculator.feature`
    Then the output should contain exactly:
      """
      ...

      """
