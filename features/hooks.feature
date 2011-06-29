Feature: Hooks into the test case lifecycle

  Cucumber does not execute anything directly. Instead
  it compiles its input into a set of test cases, each
  containing a set of actions, and executes the test cases
  by instantiating a new context for each, then ensuring
  what each action represents is applied to the system under
  test.

  This allows Cucumber to define a uniform executable 
  representation for each example you specify, regardless of
  the specific format of the input. By itself that's not too
  interesting, but Cucumber also provides a mechanism that
  enables its users to specify hooks into the test case
  lifecycle. Hooks are defined by three attributes: what they
  are associated with, the time when they fire, and a
  callback action.

  Hooks can be associated with a test case or an action.
  They can fire before, after and around their subject.

  In addition to this, hooks can be associated with metadata,
  e.g. tags.

  Scenario: Before and after test case
    Given a passing scenario "Basic Arithmetic" with:
      """
      When I add 4 and 5
      Then the result is 9
      """
    Given these passing hooks:
      | when   | what      |
      | before | test case |
      | after  | test case |
    When Cucumber executes the scenario "Basic Arithmetic"
    Then the life cycle events are:
      | before   | Basic Arithmetic |
      | dispatch | I add 4 and 5    |
      | dispatch | the result is 9  |
      | after    | Basic Arithmetic |

  Scenario: Before and after dispatch
  Scenario: Failing hook skips the rest of the test case
  Scenario: Observing results
  Scenario: Executing on particular metadata
