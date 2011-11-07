Feature: Showing the progress of a test run

  Cucumber gives an indication of its progress
  as it executes scenarios.

  Background:
    Given a scenario with:
      """
      Given a step
      Then another step
      """

  Scenario: Passing
    Given I'm using the progress formatter
    And all of the steps in the scenario pass
    When Cucumber executes the scenario
    Then the progress output looks like:
      """
      ..

      1 scenario (1 passed)
      2 steps (2 passed)

      """

  Scenario: Failing
    Given I'm using the progress formatter
    And all of the steps in the scenario fail
    When Cucumber executes the scenario
    Then the progress output looks like:
      """
      FS

      1 scenario (1 failed)
      2 steps (1 failed) (1 skipped)

      """

  Scenario: Undefined
    Given I'm using the progress formatter
    And all of the steps in the scenario are undefined
    When Cucumber executes the scenario
    Then the progress output looks like:
      """
      US

      1 scenario (1 undefined)
      2 steps (1 undefined) (1 skipped)

      """
