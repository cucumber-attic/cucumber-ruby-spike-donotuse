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
    end

    context "with one action" do
      let(:action) { double("action") }
      subject { TestCase.new(sut, action) }

      it "passes when the action passes" do
        sut.should_receive(:apply).with(action).and_return(:passed)

        subject.execute!
        subject.should be_passed
      end

      it "fails when the action fails" do
        sut.should_receive(:apply).with(action).and_return(:failed)

        subject.execute!
        subject.should be_failed
      end

      it "is pending when the action is pending" do
        sut.should_receive(:apply).with(action).and_return(:pending)

        subject.execute!
        subject.should be_pending
      end
    end
  end
end
