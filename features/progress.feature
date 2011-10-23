Feature: Showing the progress of a test run

  Cucumber gives an indication of its progress
  as it executes scenarios.

  Background:
    Given a passing scenario "Passing" with:
      """
      Given passing
      """

  Scenario: Show progress
    Given I'm using the progress formatter
    When Cucumber executes the scenario "Passing"
    Then the progress output looks like:
      """
      .

      1 scenario (1 passed)
      1 step (1 passed)

      """
