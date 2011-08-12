require 'spec_helper'

module SteppingStone
  module TextMapper
    describe Mapping do
      describe "#call" do
        let(:receiver) { double("dispatch receiver") }

        it "invokes the correct method name" do
          receiver.should_receive(:to)
          mapping = Mapping.new([:from], :to)
          mapping.call(receiver)
        end

        it "invokes a method with arguments" do
          receiver.should_receive(:hair).with("red")
          mapping = Mapping.new([/(.+) hair/], :hair)
          mapping.call(receiver, ["red hair"])
        end

        it "converts captured arguments into the specified type" do
          receiver.should_receive(:add).with(1, 2.0)
          mapping = Mapping.new([/(\d+) and (\d+)/], :add, [Integer, Float])
          mapping.call(receiver, ["1 and 2.0"])
        end

        it "raises NoMethodError when 'to' does not exist on the receiver" do
          receiver.should_receive(:to).and_raise(NoMethodError)
          mapping = Mapping.new([:from], :to)
          expect { mapping.call(receiver) }.to raise_error(NoMethodError)
        end

        it "raises an error when the action does not contain enough information to satisfy the 'from'"
        it "invokes a method on a different subject"
        it "rearranges argument order"
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
