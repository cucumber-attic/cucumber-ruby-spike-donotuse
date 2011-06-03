require 'spec_helper'

module SteppingStone
  describe TestCase do
    it "is Enumerable" do
      subject.class.should include(Enumerable)
    end

    # The pending tests are leftover from a spike. I don't want to remove them yet
    # because they are good reminders of behavior needed in other parts of the system.
    let(:server) { double("server").as_null_object }

    context "with no actions" do
      subject { TestCase.new(server) }

      xit "is pending" do
        subject.should be_pending
      end

      xit "is not passed" do
        subject.should_not be_passed
      end

      xit "is not failed" do
        subject.should_not be_failed
      end

      xit "is pending after execution" do
        subject.execute!
        subject.should be_pending
      end

      xit "sends neither the start nor end messages to the server" do
        server.should_not_receive(:start_test)
        server.should_not_receive(:end_test)

        subject.execute!
      end
    end

    context "with one action" do
      let(:action) { double("action") }
      subject { TestCase.new(server, action) }

      xit "passes when the action passes" do
        server.stub(:apply) { :passed }

        subject.execute!
        subject.should be_passed
      end

      xit "fails when the action fails" do
        server.stub(:apply) { :failed }

        subject.execute!
        subject.should be_failed
      end

      xit "is pending when the action is pending" do
        server.stub(:apply) { :pending }

        subject.execute!
        subject.should be_pending
      end

      xit "sends the start and end messages to the server" do
        server.should_receive(:start_test).with(subject).exactly(:once).ordered
        server.should_receive(:end_test).with(subject).exactly(:once).ordered

        subject.execute!
      end
    end

    context "with many actions" do
      let(:first) { double("first action") }
      let(:second) { double("second action") }

      subject { TestCase.new(first, second) }

      describe "#each" do
        it "yields its actions" do
          actions = []
          subject.each { |action| actions << action }
          actions.should == [first, second]
        end
      end

      xit "passes when all actions pass" do
        server.stub(:apply) { :passed }

        subject.execute!
        subject.should be_passed
      end

      xit "fails when the last action fails" do
        server.stub(:apply) { |action| action == first ? :passed : :failed }
        subject.execute!
        subject.should be_failed
      end

      xit "is pending when the last action is pending" do
        server.stub(:apply) { |action| action == first ? :passed : :pending }
        subject.execute!
        subject.should be_pending
      end

      xit "fails when the first action fails" do
        server.stub(:apply) { |action| action == first ? :failed : :passed }
        subject.execute!
        subject.should be_failed
      end

      xit "is pending when the first action is pending" do
        server.stub(:apply) { |action| action == first ? :pending : :passed }
        subject.execute!
        subject.should be_pending
      end

      xit "does not execute actions after a failed action" do
        server.stub(:apply).with(first) { :failed }
        server.should_not_receive(:apply).with(second)
        subject.execute!
      end

      xit "does not execute actions after a pending action" do
        server.stub(:apply).with(first) { :pending }
        server.should_not_receive(:apply).with(second)
        subject.execute!
      end
    end
  end
end
