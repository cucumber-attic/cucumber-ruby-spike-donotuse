require 'spec_helper'

module SteppingStone
  module Model
    describe Instruction do
      describe "#response_required?" do
        it "requires a response when it is a dispatch instruction" do
          inst(:dispatch, "foo").response_required?.should be_true
        end

        it "does not require one otherwise" do
          inst(:setup, "bar").response_required?.should be_false
        end
      end
    end
  end
end
