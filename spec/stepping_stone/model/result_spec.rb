require 'spec_helper'

module SteppingStone
  module Model
    describe Result do
      let(:instruction) { Instruction.new(:dispatch, ["foo"]) }
      subject { Result.new(instruction, :passed) }

      describe ".new" do
        it "defaults the result value to an empty hash" do
          result = Result.new(instruction, :passed)
          result.value.should eq({})
        end

        it "takes an optional result value" do
          result = Result.new(instruction, :passed, :value)
          result.value.should be(:value)
        end

        it "raises if the status is unrecognized" do
          expect do
            Result.new(instruction, :maglarbled)
          end.to raise_error(ArgumentError, /maglarbled/)
        end
      end

      describe "#name" do
        it "returns the type of event that triggered this result" do
          subject.name.should eq(:dispatch)
        end
      end

      describe "#arguments" do
        it "returns the array of arguments passed to the SUT mappings" do
          subject.arguments.should eq(["foo"])
        end
      end

      describe "#==" do
        it "is equal when the instruction, status and value are equal" do
          subject.should eq(Result.new(instruction, :passed))
          subject.should_not eq(Result.new(instruction, :passed, :not_nil))
        end
      end
    end
  end
end
