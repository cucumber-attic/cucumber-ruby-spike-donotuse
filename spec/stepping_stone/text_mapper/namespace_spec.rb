require 'spec_helper'

module SteppingStone
  module TextMapper
    describe Namespace do
      describe "#to_extension_module" do
        it "returns a module" do
          Namespace.new.to_extension_module.should be_an_instance_of(Module)
        end
      end

      describe "#add_mapping"

      describe "#find_mapping" do
        subject do
          ns = Namespace.new
          ns.add_mapping(Mapping.new(:foo, :bar))
          ns
        end

        it "returns a mapping with a matching 'from' pattern" do
          subject.find_mapping([:foo]).name.should == :foo
        end

        it "raises if no mapping is found" do
          expect { subject.find_mapping([:does, :not, :exist]) }.to raise_error(Namespace::UndefinedMappingError)
        end
      end

      it "creates a context with the proper helpers and attributes"

      describe "#build_context" do
        subject { Namespace.new }

        def build_mapper(name, namespace)
          from = :"from_#{name}"
          to   = :"to_#{name}"

          Module.new do
            extend namespace
            def_map from => to
            define_method(to) { to }
          end
        end

        "a context built from a module has the modules helper methods"
        "a context built from a class has an attribute referencing an instance of that class"
        "a context built from two modules has both modules' helper methods"
        "a context built from two classes has two attributes, each referencing an instance of that class"
        "a context built from a module and a class has the helper methods and the class instance"
        "helper methods can access the class instance attributes defined in the context"

        it "builds an execution context" do
          # Move dispatch assertion to Context spec, use a mock to ensure the Context Factory's new method
          # is called with the correct arguments
          build_mapper(:mapper_a, subject.to_extension_module)
          context = subject.build_context
          context.dispatch([:from_mapper_a]).should eq(:to_mapper_a)
        end

        it "exports the helper module"
        it "exports hooks"
      end
    end
  end
end
