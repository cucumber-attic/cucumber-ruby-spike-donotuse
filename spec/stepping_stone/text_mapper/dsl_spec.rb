require 'spec_helper'

module SteppingStone
  module TextMapper
    describe Dsl do
      it "aliases constants so referencing them is easier" do
        mappings = double("mappings").as_null_object
        dsl = Dsl.new(mappings, { String => :NewString, Array => :NewArray })
        constants = Module.new { extend dsl.to_module }.constants
        constants.should eq([:NewString, :NewArray])
      end
    end
  end
end
