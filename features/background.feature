Feature: Backgrounds

  Gherkin features can contain a single background section
  defining steps to be run before each scenario in that feature.
  A background is a bit like a macro that prepends the
  background's steps to each scenario or scenario outline.

  Scenario: Scenario with a background
    Given a passing background with:
      """
      Given a new calculator
      """
    And a passing scenario with:
      """
      When I add 4 and 5
      Then the result is 9
      """
    When Cucumber executes the scenario
    Then the life cycle history is:
      | event    | arguments        | status | result |
      | dispatch | a new calculator | passed | true   |
      | dispatch | I add 4 and 5    | passed | true   |
      | dispatch | the result is 9  | passed | true   |
