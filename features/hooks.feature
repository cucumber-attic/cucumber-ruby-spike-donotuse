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
    Given a passing around hook
    When Cucumber executes a scenario
    Then the around hook fires around the scenario

  @wip
  Scenario: Tagged hooks
    Given a passing before hook tagged with "foo"
    When Cucumber executes a scenario tagged with "foo"
    Then the before hook is fired before the scenario
    When Cucumber executes a scenario with no tags
    Then the before hook is not fired
