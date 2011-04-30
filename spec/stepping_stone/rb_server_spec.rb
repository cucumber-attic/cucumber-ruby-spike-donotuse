require 'spec_helper'

module SteppingStone
  describe RbServer do
    let(:context) { RbServer::Context.new }
    subject { RbServer.new(context) }

    describe "#apply" do
      it "sends the action to the context" do
        context.should_receive(:dispatch).with("foo")
        subject.apply("foo")
      end

      it "returns the result" do
        context.stub(:dispatch).with("foo").and_return("bar")
        subject.apply("foo").should == "bar"
      end
    end

    describe "#start_test" do
      it "ensures there is a new context" do
        subject.start_test(double("test case"))
        subject.context.should_not == context
      end
    end

    describe "#end_test" do
      it "doesn't do anything yet" do
        subject.should respond_to(:end_test)
      end
    end
  end
end
