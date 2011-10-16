require 'spec_helper'

module SteppingStone
  module Model
    describe TestCase do
      subject { TestCase.new("test case") }

      it "is Enumerable" do
        subject.class.should include(Enumerable)
      end

      its(:metadata) { should eq({}) }

      context "with no map instructions" do
        it "has setup and teardown instructions" do
          subject.instructions.should eq([[:setup, ["test case"]], [:teardown, ["test case"]]])
        end

        describe "#each" do
          it "yields its instructions" do
            yielded = []
            subject.each { |i| yielded << i }
            yielded.should eq(subject.instructions)
          end
        end
      end

      context "with map instructions" do
        subject { TestCase.new("test case", "foo", "bar") }

        it "converts each step into a map instruction" do
          subject.instructions.should eq([[:setup, ["test case"]], [:map, "foo"], [:map, "bar"], [:teardown, ["test case"]]])
        end

        describe "#each" do
          it "yields its instructions" do
            yielded = []
            subject.each { |i| yielded << i }
            yielded.should eq(subject.instructions)
          end
        end
      end
    end
  end
end
