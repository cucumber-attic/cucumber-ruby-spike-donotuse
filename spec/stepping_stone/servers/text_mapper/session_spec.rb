require 'spec_helper'

module SteppingStone
  module Servers
    class TextMapper
      describe Session do
        let(:success) { double("success", :halt? => false) }
        let(:failure) { double("failure", :halt? => true) }
        let(:context) { Context.new }
        subject { Session.new(context) }

        describe "#execute" do
          it "executes the instruction and returns the result" do
            context.should_receive(:dispatch).and_return(success)
            result = subject.execute(inst(:dispatch, "whatever"))
            result.should be(success)
          end

          it "returns a skipped if the last instruction failed" do
            context.stub(:dispatch).and_return(failure)
            subject.execute(inst(:dispatch, "this one fails"))
            subject.execute(inst(:dispatch, "this one is a skip")).status.should eq(:skipped)
          end
        end
      end
    end
  end
end
