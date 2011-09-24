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

              mapping.should_receive(:call).with(subject, [:foo])
              subject.dispatch([:foo])
            end

            it "returns a passed result object" do
              mappings = double("mappings")
              mapping = double("mapping")
              mappings.stub(:find_mapping).and_return(mapping)
              subject.mappings = mappings
              mapping.stub(:call).with(subject, [:foo]) { :success! }
              subject.dispatch([:foo]).should be_passed
            end
          end

          context "when a mapping does not exist" do
            it "returns an undefined result object" do
              mappings = double("mappings")
              mappings.stub(:find_mapping) do
                raise SteppingStone::TextMapper::UndefinedMappingError, [:bar]
              end
              subject.mappings = mappings
              subject.dispatch([:bar]).should be_undefined
            end
          end

          context "when a mapping invocation fails" do
            it "returns a failed result object" do
              mappings = double("mappings")
              mapping  = double("mapping")
              mappings.stub(:find_mapping).and_return(mapping)
              subject.mappings = mappings

              mapping.stub(:call) do
                raise RSpec::Expectations::ExpectationNotMetError
              end
              subject.dispatch([:go!]).should be_failed
            end
          end
        end
      end
    end
  end
end
