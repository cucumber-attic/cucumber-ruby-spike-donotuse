Feature: Execution life cycle

  Cucumber does not execute its input directly. Instead
  it compiles it into a set of test cases, each containing a
  set of instructions, and then executes the test cases. By doing
  this Cucumber ensures there is a standard execution model,
  regardless of the form each example had before it was
  compiled.

  Each instruction has a name and arguments, and Cucumber's backend
  dispatches each instruction by using its name and arguments to
  relate it to some piece of executable code. The results of the
  dispatch are then reported back, forming the execution life cycle.

  Background:
    Given a passing scenario "Basic Arithmetic" with:
      """
      When I add 4 and 5
      Then the result is 9
      """

  Scenario: No setup or teardown mappings
    Given there are no setup or teardown mappings
    When Cucumber executes the scenario
    Then the life cycle history is:
      | event    | status |
      | dispatch | passed |
      | dispatch | passed |

  Scenario: Passing mappings for every event
    Given a passing setup mapping
    And a passing teardown mapping
    When Cucumber executes the scenario
    Then the life cycle history is:
      | event    | status |
      | setup    | passed |
      | dispatch | passed |
      | dispatch | passed |
      | teardown | passed |

  Scenario: Two passing mappings on the same event
    Given a setup mapping that passes with "setup 1"
    And a setup mapping that passes with "setup 2"
    When Cucumber executes the scenario
    Then the life cycle history is:
      | event    | status |
      | setup    | passed |
      | setup    | passed |
      | dispatch | passed |
      | dispatch | passed |

  Scenario: Failing mapping skips the rest of the test case
    Given a failing setup mapping
    When Cucumber executes the scenario
    Then the life cycle history is:
      | event    | status  |
      | setup    | failed  |
      | dispatch | skipped |
      | dispatch | skipped |

  Scenario: One passing, one failing mapping on the same event
  Scenario: Executing on particular metadata
  Scenario: Observing results
