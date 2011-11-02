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
          let(:mappings) { CucumberNamespace.new }

          def mapping(from, &body)
            ::TextMapper::BlockMapping.new([from], &body)
          end

          context "when a passing mapping exists" do
            it "returns a passed result" do
              mappings.add_mapping(mapping(:from){})
              subject.mappings = mappings
              subject.dispatch(inst(:from)).should be_passed
            end
          end

          context "when a matching mapping does not exist" do
            it "returns an undefined result" do
              subject.mappings = mappings
              subject.dispatch(inst(:from)).should be_undefined
            end
          end

          context "when invocation fails" do
            it "returns a failed result" do
              mappings.add_mapping(mapping(:from){ raise RSpec::Expectations::ExpectationNotMetError })
              subject.mappings = mappings
              subject.dispatch(inst(:from)).should be_failed
            end
          end

          context "when a mapping is pending" do
            it "returns a pending result" do
              mappings.add_mapping(mapping(:from){ pending })
              subject.mappings = mappings
              subject.dispatch(inst(:from)).should be_pending
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
