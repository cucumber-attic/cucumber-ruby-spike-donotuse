require 'spec_helper'

module SteppingStone
  describe TestCase do
    let(:sut) { double("sut") }

    context "with no actions" do
      subject { TestCase.new(sut) }

      it "is pending" do
        subject.should be_pending
      end

      it "is not passed" do
        subject.should_not be_passed
      end

      it "is not failed" do
        subject.should_not be_failed
      end

      it "is pending after execution" do
        subject.execute!
        subject.should be_pending
      end

      it "sends neither the start nor end messages to the SUT"
    end

    context "with one action" do
      let(:action) { double("action") }
      subject { TestCase.new(sut, action) }

      it "passes when the action passes" do
        sut.stub(:apply) { :passed }

        subject.execute!
        subject.should be_passed
      end

      it "fails when the action fails" do
        sut.stub(:apply) { :failed }

        subject.execute!
        subject.should be_failed
      end

      it "is pending when the action is pending" do
        sut.stub(:apply) { :pending }

        subject.execute!
        subject.should be_pending
      end

      it "sends the start and end messages to the SUT"
    end

    context "with many actions" do
      let(:first) { double("first action") }
      let(:second) { double("second action") }

      subject { TestCase.new(sut, first, second) }

      it "passes when all actions pass" do
        sut.stub(:apply) { :passed }

        subject.execute!
        subject.should be_passed
      end

      it "does not execute actions after failed action" do
        sut.stub(:apply).with(first) { :failed }
        sut.should_not_receive(:apply).with(second)

        subject.execute!
        subject.should be_failed
      end

      it "does not execute actions after a pending action" do
        sut.stub(:apply).with(first) { :pending }
        sut.should_not_receive(:apply).with(second)

        subject.execute!
        subject.should be_pending
      end
    end
  end
end
