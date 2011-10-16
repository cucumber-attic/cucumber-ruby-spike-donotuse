require 'spec_helper'

module SteppingStone
  module Model
    describe TestCase do
      subject { TestCase.new("test case") }

      it "is Enumerable" do
        subject.class.should include(Enumerable)
      end

      context "with many instructions" do
        let(:first) { double("first instruction") }
        let(:second) { double("second instruction") }

        subject { TestCase.new("test case", first, second) }

        describe "#each" do
          it "yields its instructions" do
            instructions = []
            subject.each { |i| instructions << i }
            instructions.should == [first, second]
          end
        end
      end

      describe "#metadata" do
        it "is empty" do
          subject.metadata.should eq({})
        end
      end
    end
  end
end
