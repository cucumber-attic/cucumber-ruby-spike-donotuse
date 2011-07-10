require 'spec_helper'

module SteppingStone
  module TextMapper
    describe Mapping do
      describe "#call" do
        let(:target) { double("dispatch target") }

        it "invokes the correct method name" do
          target.should_receive(:to)
          mapping = Mapping.new([:from], :to)
          mapping.call(target)
        end

        it "invokes a method with arguments" do
          target.should_receive(:hair).with("red")
          mapping = Mapping.new([/(.+) hair/], :hair)
          mapping.call(target, ["red hair"])
        end

        it "converts captured arguments into the specified type" do
          target.should_receive(:add).with(1, 2.0)
          mapping = Mapping.new([/(\d+) and (\d+)/], :add, [Integer, Float])
          mapping.call(target, ["1 and 2.0"])
        end

        it "raises an error when the from does not match"
        it "raises an error when the to cannot be resolved"
        it "invokes a method on a different subject"
        it "rearranges argument order"
      end

      describe "#matches?" do
        it "returns true if the mapping matches"
        it "returns false if the mapping does not match"
      end

      describe ".from_fluent" do
        it "can anchor all strings and regexen"
        it "can set debug level"
      end

      describe "#source_location" do
        it "says where the mapping was defined"
      end
    end
  end
end
