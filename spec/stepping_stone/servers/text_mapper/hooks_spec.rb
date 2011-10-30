require 'spec_helper'

module SteppingStone
  module Servers
    class TextMapper
      module Hooks
        describe HookMapping do
          describe "#match" do
            it "matches on the first element of the pattern and the tags metadata" do
              hook = HookMapping.new(:setup, "@foo")
              hook.match([:setup], { :tags => ["@foo"] }).should be_true
            end

            it "ignores the rest of the pattern when matching" do
              hook = HookMapping.new(:blah, "@bar")
              hook.match([:blah, "hello"], { :tags => ["@bar"] }).should be_true
            end

            it "does not match when the pattern does not match but the tags do" do
              hook = HookMapping.new(:setup, "@foo")
              hook.match([:teardown], { :tags => ["@foo"] }).should be_false
            end

            it "does not match when the tags do not match but the pattern does" do
              hook = HookMapping.new(:blargle, "@foo")
              hook.match([:blargle], { :tags => ["@bar"] }).should be_false
            end

            it "matches ORed tag expressions" do
              hook = HookMapping.new(:instruction, "@foo, @bar")
              hook.match([:instruction], { :tags => ["@foo"] }).should be_true
              hook.match([:instruction], { :tags => ["@bar"] }).should be_true
              hook.match([:instruction], { :tags => ["@baz"] }).should be_false
            end

            it "matches ANDed tag expressions" do
              hook = HookMapping.new(:event, "@foo", "@bar")
              hook.match([:event], { :tags => ["@foo", "@bar"] }).should be_true
              hook.match([:event], { :tags => ["@foo"] }).should be_false
              hook.match([:event], { :tags => ["@bar"] }).should be_false
            end

            it "matches ORed-AND tag expressions" do
              hook = HookMapping.new(:teardown, "@foo, @bar", "@baz")
              hook.match([:teardown], { :tags => ["@foo", "@baz"] }).should be_true
              hook.match([:teardown], { :tags => ["@bar", "@baz"] }).should be_true
              hook.match([:teardown], { :tags => ["@foo"] }).should be_false
              hook.match([:teardown], { :tags => ["@bar"] }).should be_false
              hook.match([:teardown], { :tags => ["@foo, @baz"] }).should be_false
            end
          end

          describe "#call" do
            it "evaluates the hook body in the context" do
              ctx = Object.new
              hook = HookMapping.new(:ev, "@foo") { @ivar = :hello }
              hook.call(ctx, :arg)
              ctx.instance_variable_get(:@ivar).should eq(:hello)
            end

            it "passes the argument to the hook" do
              ctx = Object.new
              hook = HookMapping.new(:ev, "@whatever") do |a, b|
                @a, @b = a, b
              end
              hook.call(ctx, [:foo, :bar])
              ctx.instance_variable_get(:@a).should eq(:foo)
              ctx.instance_variable_get(:@b).should eq(:bar)
            end
          end

          describe "#reify!" do
            it "returns self" do
              hook = HookMapping.new(:ev, "@tag")
              hook.reify!.should be(hook)
            end
          end
        end
      end
    end
  end
end
