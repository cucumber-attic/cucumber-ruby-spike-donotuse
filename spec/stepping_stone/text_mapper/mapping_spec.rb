require 'spec_helper'

module SteppingStone
  module TextMapper
    describe Mapping do
      let(:target) { double("dispatch target") }

      it "invokes the correct method name" do
        target.should_receive(:to)
        mapping = Mapping.new("from", :to)
        mapping.dispatch(target)
      end

      it "invokes a method with arguments" do
        target.should_receive(:hair).with("red")
        mapping = Mapping.new(/(.+) hair/, :hair)
        mapping.dispatch(target, "red hair")
      end

      it "converts captured arguments into the specified type"
      it "raises an error when the from does not match"
      it "raises an error when the to cannot be resolved"
      it "invokes a method on a different subject"
      it "rearranges argument order"
    end
  end
end
