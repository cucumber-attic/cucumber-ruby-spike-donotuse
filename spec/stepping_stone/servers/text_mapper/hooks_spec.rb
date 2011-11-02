require 'spec_helper'

module SteppingStone
  module Servers
    class TextMapper
      module Hooks
        describe HookMapping do
          subject { HookMapping.new(:setup, ["@foo"]) }
          it_behaves_like "a mapping"

          describe "#match" do
            it "matches on the first element of the pattern and the tags metadata" do
              hook = HookMapping.new(:setup, ["@foo"])
              hook.match([:setup], { :tags => ["@foo"] }).should be_true
            end

            it "ignores the rest of the pattern when matching" do
              hook = HookMapping.new(:blah, ["@bar"])
              hook.match([:blah, "hello"], { :tags => ["@bar"] }).should be_true
            end

            it "does not match when the pattern does not match but the tags do" do
              hook = HookMapping.new(:setup, ["@foo"])
              hook.match([:teardown], { :tags => ["@foo"] }).should be_false
            end

            it "does not match when the tags do not match but the pattern does" do
              hook = HookMapping.new(:blargle, ["@foo"])
              hook.match([:blargle], { :tags => ["@bar"] }).should be_false
            end

            it "matches ORed tag expressions" do
              hook = HookMapping.new(:instruction, ["@foo, @bar"])
              hook.match([:instruction], { :tags => ["@foo"] }).should be_true
              hook.match([:instruction], { :tags => ["@bar"] }).should be_true
              hook.match([:instruction], { :tags => ["@baz"] }).should be_false
            end

            it "matches ANDed tag expressions" do
              hook = HookMapping.new(:event, ["@foo", "@bar"])
              hook.match([:event], { :tags => ["@foo", "@bar"] }).should be_true
              hook.match([:event], { :tags => ["@foo"] }).should be_false
              hook.match([:event], { :tags => ["@bar"] }).should be_false
            end

            it "matches ORed-AND tag expressions" do
              hook = HookMapping.new(:teardown, ["@foo, @bar", "@baz"])
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
              hook = HookMapping.new(:ev, ["@foo"]) { @ivar = :hello }
              hook.call(ctx, :arg)
              ctx.instance_variable_get(:@ivar).should eq(:hello)
            end

            it "passes the argument to the hook" do
              ctx = Object.new
              hook = HookMapping.new(:ev, ["@whatever"]) do |a, b|
                @a, @b = a, b
              end
              hook.call(ctx, [:foo, :bar])
              ctx.instance_variable_get(:@a).should eq(:foo)
              ctx.instance_variable_get(:@b).should eq(:bar)
            end
          end

          describe "#build" do
            it "returns self" do
              hook = HookMapping.new(:ev, ["@tag"])
              hook.build.should be(hook)
            end
          end
        end

        describe AroundHook do
          let(:res) { Array.new }
          subject { AroundHook.new }

          describe "#invoke" do
            it "runs the wrappers around the continuation" do
              subject.add do |continuation|
                res.push(:before)
                continuation.call
                res.push(:after)
              end

              subject.invoke { res.push(:whatever) }

              res.should eq([:before, :whatever, :after])
            end

            it "runs only matching wrappers" do
              subject.add(["@foo"]) do |cont|
                res.push(:foo)
                cont.call
              end

              subject.add(["@bar"]) do |cont|
                res.push(:bar)
                cont.call
              end

              subject.invoke(["@foo"]) { res.push(:res) }

              res.should eq([:foo, :res])
            end

            it "composes the wrappers" do
              subject.add do |continuation|
                res.push(:one)
                continuation.call
                res.push(:one)
              end

              subject.add do |continuation|
                res.push(:two)
                continuation.call
                res.push(:two)
              end

              subject.invoke { res.push(:whatever) }

              res.should eq([:two, :one, :whatever, :one, :two])
            end

            it "passes arguments to the wrappers" do
              subject.add(["@foo"]) do |cont, arg|
                arg.push(:before)
                cont.call
                arg.push(:after)
              end

              subject.invoke(["@foo"], res) { res.push(:running) }

              res.should eq([:before, :running, :after])
            end
          end

          describe "#add" do
            it "adds an execution wrapper to the around hook" do
              subject.wrappers.size.should eq(0)
              subject.add(["@bar, @baz"]) { |cont| cont.call }
              subject.wrappers.size.should eq(1)
            end
          end
        end
      end
    end
  end
end
