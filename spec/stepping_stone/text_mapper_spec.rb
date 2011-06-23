require 'spec_helper'

module SteppingStone
  module TextMapper
    module Namespace
      def self.root
        Module.new do
          def self.mappers
            @mappers ||= []
          end

          def self.all_mappings
            mappers.inject([]) do |acc, mapper|
              acc << mapper.mappings
            end.flatten
          end

          def self.extended(mapper)
            mapper.extend(Dsl)
            mappers << mapper
          end
        end
      end
    end

    describe Namespace do
      describe ".root" do
        it "builds a unique namespace" do
          ns1 = Namespace.root
          ns2 = Namespace.root
          ns1.should_not be(ns2)
        end

        it "returns a module" do
          Namespace.root.should be_an_instance_of(Module)
        end
      end

      describe "enclosing mappers within a namespace" do
        subject { Namespace.root }

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
            build_mapper(:mapper_a)
            build_mapper(:mapper_b)
          end

          describe "#all_mappings" do
            xit "exports mappings" do
              subject.all_mappings.collect(&:name).should == [:from_mapper_a, :from_mapper_b]
            end
          end

          it "exports mappings"
          it "exports the helper module"
          it "exports hooks"
        end
      end
    end
  end
end
