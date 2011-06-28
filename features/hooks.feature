Feature: Hooks into the test case lifecycle

  Cucumber does not execute anything directly. Instead
  it compiles its input into a set of test cases and executes
  each test case. This allows Cucumber to define a uniform
  executable representation for each example you specify,
  regardless of the specific format of the input. By itself
  that's not too interesting, but Cucumber also provides a
  mechanism that enables its users to specify hooks into
  the test case lifecycle. Hooks are defined by three
  attributes: the event they are associated with, the time
  when they fire, and a callback action.

  There are three events: setup, teardown and dispatch.
  The setup event occurs immediately before test case
  execution begins, and teardown immediately after. The
  dispatch event is sent when an action is dispatched against
  the system under test.

  The time of a hook dictates when in relation to an event it
  is fired. This can be before, after or around.

  In addition to this, hooks can be associated with metadata,
  e.g. tags.

  Scenario: Event hooks
    Given a passing scenario "Basic Arithmetic" with:
      """
      When I add 4 and 5
      Then the result is 9
      """
    Given these passing hooks:
      | When   | Event    |
      | before | setup    |
      | after  | teardown |
    When Cucumber executes the scenario "Basic Arithmetic"
    # not quite there yet
    Then the test case life cycle events are fired in this order:
      | hook     | before setup     |
      | setup    | Basic Arithmetic |
      | dispatch | I add 4 and 5    |
      | dispatch | the result is 9  |
      | after    | Basic Arithmetic |
      | hook     | after teardown   |

  Scenario: Failing hook skips the rest of the test case
  Scenario: Observing results
  Scenario: Executing on particular metadata
