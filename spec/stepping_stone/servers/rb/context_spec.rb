require 'spec_helper'

module SteppingStone
  module Servers
    module Rb
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
          context "when a mapping exists" do
            it "invokes the mapping" do
              mappings = double("mappings")
              mapping  = double("mapping")
              mappings.stub(:find_mapping).and_return(mapping)
              subject.mappings = mappings

              mapping.should_receive(:call).with(subject, [:foo])
              subject.dispatch([:foo])
            end
          end
        end
      end
    end
  end
end
