require 'spec_helper'

module SteppingStone
  describe TestCase do
    let(:sut)    { double("sut") }
    let(:action) { double("action") }

    subject { TestCase.new(sut, action) }

    it "passes when all actions pass" do
      sut.should_receive(:apply).with(action).and_return(:passed)

      subject.execute!
      subject.should be_passed
    end

    it "fails when an action fails" do
      sut.should_receive(:apply).with(action).and_return(:failed)

      subject.execute!
      subject.should be_failed
    end

    it "is pending when an action is pending" do
      sut.should_receive(:apply).with(action).and_return(:pending)

      subject.execute!
      subject.should be_pending
    end

    it "is pending when it has no actions"
  end
end
