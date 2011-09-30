Feature: Life cycle event listeners

  TODO: Be brief

  Cucumber does not execute its input directly. Instead
  it compiles it into a set of test cases, each containing a
  set of actions, and then executes the test cases. By doing
  this Cucumber ensures there is a standard execution model,
  regardless of the form each example had before it was
  compiled.

  Just having a standard model, however, isn't worth anything
  if you can't tie that model to the software you are
  developing, so Cucumber also provides a backend layer that
  maps from test case actions to user-provided methods or
  functions in the system under test. It is the responsibility
  of these functions to setup, modify and verify the state of
  the software under test in a way that fulfils the intent and
  meaning of the input examples.

  This communication between the execution model and the backend
  takes the form of a series of events whose results determine
  the outcome of the life cycle of each test case, whether it
  passed or failed, etc. To get started the user must register
  listeners for the "apply" events that correspond to test case
  actions (how exactly that is done will differ from backend to
  backend). If necessary or useful they may also register
  listeners for the other events in the test case life cycle.

  Background:
    Given a passing scenario "Basic Arithmetic" with:
      """
      When I add 4 and 5
      Then the result is 9
      """

  Scenario: No listeners
    Given there are no listeners
    When Cucumber executes the scenario "Basic Arithmetic"
    Then the life cycle history is:
      | event | name            | status |
      | map   | I add 4 and 5   | passed |
      | map   | the result is 9 | passed |

  Scenario: Passing listeners for every event
    Given these passing listeners:
      | event        | filter |
      | setup        | none   |
      | teardown     | none   |
    When Cucumber executes the scenario "Basic Arithmetic"
    Then the life cycle history is:
      | event        | name             | status |
      | setup        | Basic Arithmetic | passed |
      | map          | I add 4 and 5    | passed |
      | map          | the result is 9  | passed |
      | teardown     | Basic Arithmetic | passed |

  Scenario: Failing listener skips the rest of the test case
  Scenario: Two passing listeners on the same event
  Scenario: One passing, one failing listener on the same event
  Scenario: Executing on particular metadata
  Scenario: Observing results
