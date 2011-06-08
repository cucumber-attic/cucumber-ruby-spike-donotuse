Feature: sst exec
  Usage of the 'sst exec' command

  Background:
    Given a file named "sst/sst_helper.rb" with:
      """
      require 'stepping_stone'
      require 'rspec/expectations'
      """
    And a file named "sst/mappers/calculator_mapper.rb" with:
      """
      require 'sst_helper'

      module CalculatorMapper
        extend SteppingStone::TextMapper

        def_map "a calculator"                       => :create
        def_map /(\d+) and (\d+) are added together/ => [:add, Integer, Integer]
        def_map /the answer is (\d+)/                => :assert_answer

        def create
          @calculator = Class.new do
            attr_reader :answer

            def initialize
              @answer = 0
            end

            def add(m, n)
              @answer += m + n
            end
          end.new
        end

        def add(n, m)
          @calculator.add(n, m)
        end

        def assert_answer(r)
          @calculator.answer.should == r.to_i
        end
      end
      """

  Scenario: Executing a passing scenario
    Given a file named "sst/features/calculator.feature" with:
      """
      Feature: Calculator
        Scenario: Addition
          Given a calculator
          When 5 and 4 are added together
          Then the answer is 9

      """
    When I successfully run `sst exec sst/features/calculator.feature`
    Then the output should contain exactly:
      """
      ...

      """

  Scenario: Executing a failing scenario
    Given a file named "sst/features/calculator.feature" with:
      """
      Feature: Calculator
        Scenario: Bad Addition
          Given a calculator
          When 6 and 10 are added together
          Then the answer is 20

      """
    When I successfully run `sst exec sst/features/calculator.feature`
    Then the output should contain exactly:
      """
      ..F

      """

  Scenario: Executing a scenario with a missing mapping
    Given a file named "sst/features/calculator.feature" with:
      """
      Feature: Calculator
        Scenario: Pending Addition
          Given a calculator
          When 6 and 10 are added together
          # This next step is missing a mapping
          And 5 is added to the result
          Then the answer is 20

      """
    When I successfully run `sst exec sst/features/calculator.feature`
    Then the output should contain exactly:
      """
      ..MP

      """

