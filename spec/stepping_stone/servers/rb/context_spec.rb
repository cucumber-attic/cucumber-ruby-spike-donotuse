require 'spec_helper'

module SteppingStone
  module Servers
    module Rb
      describe "Context" do
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

            context = Context.new
            context.mappers = [helper_a, helper_b]
            context.helper_a.should eq(:helper_a)
            context.helper_b.should eq(:helper_b)
          end
        end
      end
    end
  end
end
