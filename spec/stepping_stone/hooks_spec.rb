require 'spec_helper'

module SteppingStone
  describe Hooks do
    describe "#invoke" do
      it "invokes hooks in the right order" do
        results = []
        subject.add(:before) { results.push(:before) }
        subject.add(:after) { results.push(:after) }
        subject.add(:around) do |run|
          results.push(:around_before)
          run.call
          results.push(:around_after)
        end
        subject.invoke { results.push(:run) }
        results.should eq([:around_before, :before, :run, :after, :around_after])
      end

      it "passes arguments to the hooks" do
        res = []
        subject.add(:around) do |run, arg|
          res.push(:"around_before_#{arg}")
          run.call
          res.push(:"around_after_#{arg}")
        end
        subject.add(:before) { |arg| res.push(:"before_#{arg}") }
        subject.add(:after)  { |arg| res.push(:"after_#{arg}") }
        subject.invoke([], :arg) {}
        res.should eq([:around_before_arg, :before_arg, :after_arg, :around_after_arg])
      end

      context "with a tagged hook" do
        it "invokes the hook when the tag matches" do
          res = []
          subject.add(:before, "@foo") { res.push(:before) }
          subject.invoke(["@foo"]) { res.push(:run) }
          res.should eq([:before, :run])
        end

        it "invokes ORed hooks" do
          res = []
          subject.add(:after, "@foo, @bar") { res.push(:after) }
          subject.invoke(["@foo"]) { res.push(:foo) }
          subject.invoke(["@bar"]) { res.push(:bar) }
          subject.invoke { res.push(:none) }
          res.should eq([:foo, :after, :bar, :after, :none])
        end

        it "invokes ANDed hooks" do
          res = []
          subject.add(:around, "@foo", "@bar") do |run|
            res.push(:before)
            run.call
            res.push(:after)
          end
          subject.invoke(["@foo"]) { res.push(:foo) }
          subject.invoke(["@bar"]) { res.push(:bar) }
          subject.invoke(["@foo", "@bar"]) { res.push(:foo_bar) }
          res.should eq([:foo, :bar, :before, :foo_bar, :after])
        end

        it "invokes hooks with ORs and ANDs" do
          res = []
          subject.add(:before, "@foo, @bar", "@baz") { res.push(:before) }
          subject.invoke(["@foo", "@baz"]) { res.push(:run) }
          subject.invoke(["@bar", "@baz"]) { res.push(:run) }
          subject.invoke(["@foo"]) { res.push(:run) }
          subject.invoke(["@baz"]) { res.push(:run) }
          subject.invoke(["@foo, @bar"]) { res.push(:run) }
          res.should eq([:before, :run, :before, :run, :run, :run, :run])
        end
      end
    end

    describe "#filter" do
      it "returns an array of hooks by type" do
        subject.add(:around) {}
        subject.add(:before) {}
        subject.add(:after)  {}

        around, before, after = subject.filter([])

        around.should have(1).hook
        before.should have(1).hook
        after.should  have(1).hook
      end

      it "returns the hooks matching the filter" do
        subject.add(:around, "@foo") {}
        subject.add(:around, "@bar") {}
        around, _, _= subject.filter(["@foo"])
        around.should have(1).hook
      end

      it "always selects untagged hooks" do
        subject.add(:before) {}
        subject.add(:before, "@foo") {}
        _, before, _ = subject.filter(["@foo"])
        before.should have(2).hooks
      end
    end

    describe "#add" do
      it "adds before hooks" do
        subject.hooks[:before].should have(0).hooks
        subject.add(:before) {}
        subject.hooks[:before].should have(1).hook
      end

      it "adds after hooks" do
        subject.hooks[:after].should have(0).hooks
        subject.add(:after) {}
        subject.hooks[:after].should have(1).hook
      end

      it "adds around hooks" do
        subject.hooks[:around].should have(0).hooks
        subject.add(:around) {}
        subject.hooks[:around].should have(1).hook
      end
    end
  end
end
