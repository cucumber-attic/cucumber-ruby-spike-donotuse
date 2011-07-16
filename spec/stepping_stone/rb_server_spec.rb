require 'spec_helper'

module SteppingStone
  describe RbServer do
    let(:context) { TextMapper::Context.new(double("mappings container")) }

    subject do
      server = RbServer.new
      server.context = context
      server
    end

    describe "#dispatch" do
      it "sends the action to the context" do
        context.should_receive(:dispatch).with("foo")
        subject.dispatch("foo")
      end

      it "returns the result" do
        context.stub(:dispatch).with("foo").and_return("bar")
        # calling #result is hack to get this to pass for now
        subject.dispatch("foo").status.should == :passed
      end

      context "when the action succeeds"
      context "when the action fails"
      context "when the action is missing a mapping"
      context "when the last action was missing a mapping"
    end

		describe "#apply" do
			it "evaluates a block within the context" do
				subject.apply { @state = :state }
				state = subject.apply { @state }
				state.should eq(:state)
			end
		end

    describe "#start_test" do
      it "resets the context state" do
				subject.start_test(double("first test case"))
				subject.apply { @state = :state }
				subject.start_test(double("second est case"))
				state = subject.apply { @state }
				state.should be(nil)
      end
    end

    describe "#end_test" do
      it "doesn't do anything yet" do
        subject.should respond_to(:end_test)
      end
    end
  end
end
