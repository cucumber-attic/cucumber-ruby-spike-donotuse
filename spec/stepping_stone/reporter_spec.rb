require 'spec_helper'

module SteppingStone
  describe Reporter do
    def setup(name)
      Model::Result.new(:undefined, nil, Model::Instruction.new(:setup, [name]))
    end

    def teardown(name)
      Model::Result.new(:undefined, nil, Model::Instruction.new(:teardown, [name]))
    end

    def map(pattern, status)
      Model::Result.new(status, nil, Model::Instruction.new(:map, [pattern]))
    end
    
    it "keeps a record of events" do
      reporter = Reporter.new
      reporter.record(setup("test case"))
      reporter.record(map("foo", :passed))
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
      reporter.record(map("foo", :passed))
      reporter.record(teardown("test case 1"))
      reporter.record(setup("test case 2"))
      reporter.record(map("foo", :failed))
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
