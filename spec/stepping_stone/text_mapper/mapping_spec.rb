require 'spec_helper'

module SteppingStone
  module TextMapper
    describe Mapping do
      let(:context) { double("execution context") }

      it "invokes the correct method name" do
        context.should_receive(:to)
        mapping = Mapping.new("from", :to)
        mapping.dispatch(context)
      end

      it "invokes a method with arguments" do
        context.should_receive(:hair).with("red")
        mapping = Mapping.new(/(.+) hair/, :hair)
        mapping.dispatch(context, "red hair")
      end

      it "converts captured arguments into the specified type"
      it "raises an error when the from does not match"
      it "raises an error when the to cannot be resolved"
      it "invokes a method on a different subject"
      it "rearranges argument order"
    end
  end
end
