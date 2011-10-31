require 'spec_helper'

module SteppingStone
  module Servers
    class TextMapper
      describe CucumberNamespace do
        subject { CucumberNamespace.new }
        let(:ctx) { Object.new }

        def with_dsl(&body)
          dsl = subject.to_extension_module
          Module.new do
            extend dsl
            module_eval(&body)
          end
        end

        describe ".new" do
          it "aliases DocString and DataTable in the DSL" do
            expect do
              lambda do |dsl|
                Module.new do |mod|
                  extend dsl
                  mod::DocString
                  mod::DataTable
                end
              end.call(subject.to_extension_module)
            end.to_not raise_error(NameError, /uninitialized constant/)
          end

          it "adds a before hook method to the DSL" do
            with_dsl do
              before do
                @before = :before
              end
            end

            hook = subject.find_mapping([:setup])
            hook.call(ctx)
            ctx.instance_variable_get(:@before).should eq(:before)
          end

          it "adds an after hook method to the DSL" do
            with_dsl do
              after do
                @after = :after
              end
            end

            hook = subject.find_mapping([:teardown])
            hook.call(ctx)
            ctx.instance_variable_get(:@after).should eq(:after)
          end

          it "adds an around hook method to the DSL" do
            with_dsl do
              around do |continuation, ctx|
                ctx.instance_variable_set(:@around, :around)
                continuation.call
              end
            end

            subject.wrap_execution_of(ctx) { :continuing }
            ctx.instance_variable_get(:@around).should eq(:around)
          end
        end
      end
    end
  end
end
