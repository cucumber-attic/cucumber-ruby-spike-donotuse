require 'spec_helper'

module SteppingStone
  module TextMapper
    describe "a mapper" do
      subject do
        Module.new do
          extend TextMapper
          def_map :from_action => :to_method
          def to_method
            :to_method
          end
        end
      end

      it "exports its mappings" do
        subject.mappings.should have(1).mapping
      end

      it "exports its hooks"
    end
  end
end
