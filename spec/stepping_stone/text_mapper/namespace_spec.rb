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

      describe "enclosing mappers within a namespace" do
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

        context "with one mapper" do
          # create the enclosing namespace
          # extend it with mappers
          # build the context
          # verify that the context dispatches actions correctly
          before { build_mapper(:mapper_a, subject) }

          describe "#all_mappings" do
            it "exports mappings" do
              subject.all_mappings.collect(&:name).should == [:from_mapper_a]
            end
          end

          it "exports the helper module"
          it "exports hooks"
        end

        context "with many mappers" do
          before do
            build_mapper(:mapper_a, subject)
            build_mapper(:mapper_b, subject)
          end

          describe "#all_mappings" do
            it "exports mappings" do
              subject.all_mappings.collect(&:name).should == [:from_mapper_a, :from_mapper_b]
            end
          end

          it "exports the helper module"
          it "exports hooks"
        end
      end
    end
  end
end
