require 'spec_helper'

module SteppingStone
  module TextMapper
    describe Namespace do
      describe ".build" do
        it "builds a unique namespace" do
          ns1 = Namespace.build
          ns2 = Namespace.build
          ns1.should_not be(ns2)
        end

        it "returns a module" do
          Namespace.build.should be_an_instance_of(Module)
        end
      end

      it "creates a collection of mappings"
      it "creates a context with the proper helpers and attributes"

      describe "#build_context" do
        subject { Namespace.build }

        def build_mapper(name, namespace)
          from = :"from_#{name}"
          to   = :"to_#{name}"

          Module.new do
            extend namespace
            def_map from => to
            define_method(to) { to }
          end
        end

        before do
          build_mapper(:mapper_a, subject)
          build_mapper(:mapper_b, subject)
        end

        # create the enclosing namespace
        # extend it with mappers
        # build the context
        # verify that the context dispatches actions correctly

        "a context built from a module has the modules helper methods"
        "a context built from a class has an attribute referencing an instance of that class"
        "a context built from two modules has both modules' helper methods"
        "a context built from two classes has two attributes, each referencing an instance of that class"
        "a context built from a module and a class has the helper methods and the class instance"
        "helper methods can access the class instance attributes defined in the context"

        it "builds an execution context" do
          namespace = Namespace.build
          build_mapper(:mapper_a, namespace)
          context = namespace.build_context
          context.dispatch([:from_mapper_a]).should eq(:to_mapper_a)
        end

        describe "#all_mappings" do
          it "exports mappings" do
            subject.all_mappings.collect(&:name).should eq([:from_mapper_a, :from_mapper_b])
          end
        end

        it "exports the helper module"
        it "exports hooks"
      end
    end
  end
end
