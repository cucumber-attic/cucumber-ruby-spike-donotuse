Feature: Life cycle event listeners

  TODO: Be brief

  Cucumber does not execute its input directly. Instead
  it compiles it into a set of test cases, each containing a
  set of instructions, and then executes the test cases. By doing
  this Cucumber ensures there is a standard execution model,
  regardless of the form each example had before it was
  compiled.

  Just having a standard model, however, isn't worth anything
  if you can't tie that model to the software you are
  developing, so Cucumber also provides a backend layer that
  maps from test case instructions to user-provided methods or
  functions in the system under test. It is the responsibility
  of these functions to setup, modify and verify the state of
  the software under test in a way that fulfils the intent and
  meaning of the input examples.

  This communication between the execution model and the backend
  takes the form of a series of events whose results determine
  the outcome of the life cycle of each test case, whether it
  passed or failed, etc. To get started the user must register
  listeners for the "apply" events that correspond to test case
  instructions (how exactly that is done will differ from backend to
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
      | event | arguments       | status | result |
      | map   | I add 4 and 5   | passed | true   |
      | map   | the result is 9 | passed | true   |

  Scenario: Passing listeners for every event
    Given a passing setup listener
    And a passing teardown listener
    When Cucumber executes the scenario "Basic Arithmetic"
    Then the life cycle history is:
      | event        | arguments        | status | result |
      | setup        | Basic Arithmetic | passed | passed |
      | map          | I add 4 and 5    | passed | true   |
      | map          | the result is 9  | passed | true   |
      | teardown     | Basic Arithmetic | passed | passed |

  Scenario: Two passing listeners on the same event
    Given a setup listener that passes with "setup 1"
    And a setup listener that passes with "setup 2"
    When Cucumber executes the scenario "Basic Arithmetic"
    Then the life cycle history is:
      | event | arguments        | status | result  |
      | setup | Basic Arithmetic | passed | setup 1 |
      | setup | Basic Arithmetic | passed | setup 2 |
      | map   | I add 4 and 5    | passed | true    |
      | map   | the result is 9  | passed | true    |

  Scenario: Failing listener skips the rest of the test case
    Given a failing setup listener
    When Cucumber executes the scenario "Basic Arithmetic"
    Then the life cycle history is:
      | event | arguments        | status  | result    |
      | setup | Basic Arithmetic | failed  | exception |
      | map   | I add 4 and 5    | skipped | n/a       |
      | map   | the result is 9  | skipped | n/a       |

  Scenario: One passing, one failing listener on the same event
  Scenario: Executing on particular metadata
  Scenario: Observing results
