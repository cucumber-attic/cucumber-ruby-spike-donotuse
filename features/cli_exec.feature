Feature: CLI exec
  Usage of the 'cuke exec' command

  Background:
    Given a file named "cukes/cukes_helper.rb" with:
      """
      require 'stepping_stone'
      require 'rspec/expectations'
      """
    And a file named "cukes/mappers/calculator_mapper.rb" with:
      """
      require 'cukes_helper'

      module CalculatorMapper
        extend SteppingStone::Mapper

        def_map "a calculator"                                   => :create
        def_map /(\d+) and (\d+) are added together/             => [:add, Integer, Integer]
        def_map ["these numbers are added together:", DocString] => :add_script
        def_map /(\d+) and (\d+) are multiplied/                 => [:multiply, Integer, Integer]
        def_map /the answer is (\d+)/                            => :assert_answer
        def_map /the answer is not (\d+)/                        => :assert_not_answer

        def create
          @calculator = Class.new do
            attr_reader :answer

            def initialize
              @answer = 0
            end

            def add(m, n)
              @answer += m + n
            end

            def multiply(m, n)
              @answer += m * n
            end

            def add_script(script)
              @answer += script.inject(&:+)
            end
          end.new
        end

        def add(n, m)
          @calculator.add(n, m)
        end

        def add_script(script)
          @calculator.add_script(script.split.map(&:to_i))
        end

        def multiply(m, n)
          @calculator.multiply(m, n)
        end

        def assert_answer(r)
          @calculator.answer.should == r.to_i
        end

        def assert_not_answer(r)
          @calculator.answer.should_not == r.to_i
        end
      end
      """

  Scenario: Executing a passing scenario
    Given a file named "cukes/features/calculator.feature" with:
      """
      Feature: Calculator
        Scenario: Addition
          Given a calculator
          When 5 and 4 are added together
          Then the answer is 9

      """
    When I successfully run `cuke exec cukes/features/calculator.feature`
    Then the output should contain exactly:
      """
      ...

      """

  Scenario: Executing a failing scenario
    Given a file named "cukes/features/calculator.feature" with:
      """
      Feature: Calculator
        Scenario: Bad Addition
          Given a calculator
          When 6 and 10 are added together
          Then the answer is 20
          And the answer is not 16

      """
    When I successfully run `cuke exec cukes/features/calculator.feature`
    Then the output should contain exactly:
      """
      ..FS

      """

  Scenario: Executing a scenario with an undefined mapping
    Given a file named "cukes/features/calculator.feature" with:
      """
      Feature: Calculator
        Scenario: Undefined Mapping
          Given a calculator
          When 6 and 10 are added together
          # This next step's mapping is undefined
          And 5 is added to the result
          Then the answer is 20

      """
    When I successfully run `cuke exec cukes/features/calculator.feature`
    Then the output should contain exactly:
      """
      ..US

      """

  Scenario: Executing a scenario with a doc string
    Given a file named "cukes/features/calculator.feature" with:
      """
      Feature: Calculator
        Scenario: Addition script
          Given a calculator
          When these numbers are added together:
            \"\"\"
            4
            10
            \"\"\"
          Then the answer is 14

      """
    When I successfully run `cuke exec cukes/features/calculator.feature`
    Then the output should contain exactly:
      """
      ...

      """

  Scenario: Executing two scenarios
    Given a file named "cukes/features/calculator.feature" with:
      """
      Feature: Calculator
        Scenario: Addition
          Given a calculator
          When 5 and 4 are added together
          Then the answer is 9

        Scenario: Multiplication
          Given a calculator
          When 8 and 4 are multiplied
          Then the answer is 32

      """
    When I successfully run `cuke exec cukes/features/calculator.feature`
    Then the output should contain exactly:
      """
      ......

      """
