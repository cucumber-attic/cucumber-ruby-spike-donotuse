require 'spec_helper'

module SteppingStone
  module Servers
    class TextMapper
      describe Invocation do
        it_behaves_like "a mapping"

        let(:ctx) { Object.new }

        let(:foo) { ::TextMapper::BlockMapping.new([:from]) { @foo = :foo } }
        let(:bar) { ::TextMapper::BlockMapping.new([:from]) { @bar = :bar } }

        subject { Invocation.new([foo, bar]) }

        describe "#call" do
          it "calls the mappings" do
            subject.call(ctx, [])
            ctx.instance_variable_get(:@foo).should eq(:foo)
            ctx.instance_variable_get(:@bar).should eq(:bar)
          end

          it "collects the results of calling the mappings" do
            subject.call(ctx, []).should eq({
              foo.id => :foo,
              bar.id => :bar
            })
          end

          it "passes the ctx and arguments to the mappings" do
            foo.should_receive(:call).with(ctx, :foo)
            bar.should_receive(:call).with(ctx, :foo)
            subject.call(ctx, :foo)
          end
        end
      end
    end
  end
end
