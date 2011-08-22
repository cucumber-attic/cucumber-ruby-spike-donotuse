Feature: Backgrounds

  Gherkin features can contain a single background section
  defining steps to be run before each scenario in that feature.
  A background is a bit like a macro that prepends the
  background's steps to each scenario or scenario outline.

  Scenario: Scenario with a background
    Given a passing background with:
      """
      Given I log in as "Bob"
      """
    And a passing scenario "Arithmetic" with:
      """
      When I add 4 and 5
      Then the result is 9
      """
    When Cucumber executes the scenario "Arithmetic"
    Then the life cycle history is:
      | event | name              | status |
      | apply | I log in as "Bob" | passed |
      | apply | I add 4 and 5     | passed |
      | apply | the result is 9   | passed |
