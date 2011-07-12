require 'spec_helper'

module SteppingStone
  describe RbServer do
    let(:context) { TextMapper::Context.new(double("mappings container")) }

    subject do
      server = RbServer.new
      server.context = context
      server
    end

    describe "#apply" do
      it "sends the action to the context" do
        context.should_receive(:dispatch).with("foo")
        subject.apply("foo")
      end

      it "returns the result" do
        context.stub(:dispatch).with("foo").and_return("bar")
        # calling #result is hack to get this to pass for now
        subject.apply("foo").status.should == :passed
      end

      context "when the action succeeds"
      context "when the action fails"
      context "when the action is missing a mapping"
      context "when the last action was missing a mapping"
    end

    describe "#start_test" do
      it "ensures there is a new context" do
        subject.start_test(double("test case", :name => "test case"))
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
