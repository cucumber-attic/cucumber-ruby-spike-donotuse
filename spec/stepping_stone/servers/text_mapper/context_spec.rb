require 'spec_helper'

module SteppingStone
  module Servers
    class TextMapper
      describe "Context" do
        subject { Context.new }

        describe "#mappers=" do
          it "mixes in the methods from the helper modules" do
            helper_a = Module.new do
              def helper_a
                :helper_a
              end
            end

            helper_b = Module.new do
              def helper_b
                :helper_b
              end
            end

            subject.mappers = [helper_a, helper_b]
            subject.helper_a.should eq(:helper_a)
            subject.helper_b.should eq(:helper_b)
          end
        end

        describe "#dispatch" do
          context "when a passing mapping exists" do
            it "invokes the mapping" do
              mappings = double("mappings")
              mapping  = double("mapping")
              mappings.stub(:find_mapping).and_return(mapping)
              subject.mappings = mappings

              mapping.should_receive(:call).with(subject, [:map, :foo])
              subject.dispatch(inst(:map, [:foo]))
            end

            it "returns a passed result" do
              mappings = double("mappings")
              mapping = double("mapping")
              mappings.stub(:find_mapping).and_return(mapping)
              subject.mappings = mappings
              mapping.stub(:call).with(subject, [:map, :foo]) { :success! }
              subject.dispatch(inst(:map, [:foo])).should be_passed
            end
          end

          context "when a mapping does not exist" do
            it "returns an undefined result" do
              mappings = double("mappings")
              mappings.stub(:find_mapping) do
                raise ::TextMapper::UndefinedMappingError, [:bar]
              end
              subject.mappings = mappings
              subject.dispatch(inst(:map, [:bar])).should be_undefined
            end
          end

          context "when a mapping invocation fails" do
            it "returns a failed result" do
              mappings = double("mappings")
              mapping  = double("mapping")
              mappings.stub(:find_mapping).and_return(mapping)
              subject.mappings = mappings

              mapping.stub(:call) do
                raise RSpec::Expectations::ExpectationNotMetError
              end
              subject.dispatch(inst(:map, [:go!])).should be_failed
            end
          end

          context "when a mapping calls pending" do
            it "returns a pending result" do
              mapping = ::TextMapper::Mapping.from_primitives([:do_pending], [:pending])
              mappings = double("mappings")
              mappings.stub(:find_mapping).and_return(mapping)
              subject.mappings = mappings
              subject.dispatch(inst(:map, [:do_pending])).should be_pending
            end
          end
        end

        describe "#pending" do
          it "raises a pending exception" do
            expect do
              subject.pending
            end.to raise_error(SteppingStone::Pending)
          end
        end
      end
    end
  end
end
