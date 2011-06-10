require 'spec_helper'

module SteppingStone
  module TextMapper
    describe "Context" do
      describe ".including" do
        it "ensures the modules are included within the context" do
          Foo = Module.new
          Bar = Module.new
          Context.include_mappers([Foo, Bar])
          Context.should include(Foo, Bar)
        end
      end
    end
  end
end
