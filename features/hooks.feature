Feature: Environment Hooks

  Use environment hooks to configure the environment
  for your application.

  Scenario: Before and After
    Given a passing before hook
    And a passing after hook
    When Cucumber executes a scenario
    Then the before hook is fired before the scenario
    And the after hook is fired after the scenario

  Scenario: Around
  Scenario: Tagged hooks

