require 'spec_helper'

module SteppingStone
  describe Reporter do
    def setup(name)
      Model::Result.new(inst(:setup, name), :undefined)
    end

    def teardown(name)
      Model::Result.new(inst(:teardown, name), :undefined)
    end

    def dispatch(pattern, status)
      Model::Result.new(inst(:dispatch, pattern), status)
    end

    it "keeps a record of events" do
      reporter = Reporter.new
      reporter.record(setup("test case"))
      reporter.record(dispatch("foo", :passed))
      reporter.record(teardown("test case"))
      reporter.should have(3).events
    end

    it "keeps a record of test cases from the events" do
      reporter = Reporter.new
      reporter.record(setup("test case 1"))
      reporter.record(teardown("test case 1"))
      reporter.record(setup("test case 2"))
      reporter.record(teardown("test case 2"))
      reporter.test_cases.should eq(["test case 1", "test case 2"])
    end

    it "tracks test case results" do
      reporter = Reporter.new
      reporter.record(setup("test case 1"))
      reporter.record(dispatch("foo", :passed))
      reporter.record(teardown("test case 1"))
      reporter.record(setup("test case 2"))
      reporter.record(dispatch("foo", :failed))
      reporter.record(teardown("test case 2"))
      reporter.result_for("test case 1").should eq(:passed)
      reporter.result_for("test case 2").should eq(:failed)
    end

    it "knows the last important event"
    it "maintains a summary of events"

    it "notifies observers when it has recieved a new event"
    it "distinguishes between important and unimportant events"
  end
end
