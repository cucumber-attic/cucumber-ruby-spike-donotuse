require 'spec_helper'

module SteppingStone
  module Model
    describe TestCase do
      subject { TestCase.new("test case") }

      it "is Enumerable" do
        subject.class.should include(Enumerable)
      end

      context "with many actions" do
        let(:first) { double("first action") }
        let(:second) { double("second action") }

        subject { TestCase.new("test case", first, second) }

        describe "#each" do
          it "yields its actions" do
            actions = []
            subject.each { |action| actions << action }
            actions.should == [first, second]
          end
        end
      end
    end
  end
end
