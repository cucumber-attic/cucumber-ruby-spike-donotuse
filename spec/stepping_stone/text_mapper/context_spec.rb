require 'spec_helper'

module SteppingStone
  module TextMapper
    describe "Context" do
      it "mixes in the methods from the helper module"
      it "dispatches actions to methods"
      it "raises UndefinedMappingError when no mapping matches an action"

      describe ".new" do
        it "adds the Mappers' helper methods as instance methods" do
          MapperA = Module.new do
            extend TextMapper
            def helper_a
              :helper_a
            end
          end

          MapperB = Module.new do
            extend TextMapper
            def helper_b
              :helper_b
            end
          end

          c = Context.new([MapperA, MapperB])
          c.helper_a.should == :helper_a
          c.helper_b.should == :helper_b
        end
      end
    end
  end
end
