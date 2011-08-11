require 'spec_helper'

module SteppingStone
  module TextMapper
    describe Dsl do
      let(:namespace) { double("namespace").as_null_object }

      def within(namespace, &script)
        Module.new do
          extend Dsl.new(namespace).to_module
          module_eval(&script)
        end
      end

      it "aliases constants so referencing them is easier" do
        dsl = Dsl.new(namespace, { String => :NewString, Array => :NewArray })
        constants = Module.new { extend dsl.to_module }.constants
        constants.should eq([:NewString, :NewArray])
      end

      describe ".def_map" do
        it "stores mappings in the namespace" do
          namespace.should_receive(:add_mapping).with(an_instance_of(Mapping))
          within(namespace) { def_map :from => :to }
        end
      end
    end
  end
end
