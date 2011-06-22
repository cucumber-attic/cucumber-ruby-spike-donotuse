require 'spec_helper'

module SteppingStone
  module TextMapper
    describe "Context" do
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
