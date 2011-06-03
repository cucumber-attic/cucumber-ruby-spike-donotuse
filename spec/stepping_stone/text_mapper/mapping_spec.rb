require 'spec_helper'

module SteppingStone
  module TextMapper
    class TestRecorder
      attr_reader :events

      def initialize(mapping)
        @mapping = mapping
        @events = {}
      end

      def exec
        instance_eval(&@mapping.to_proc)
      end

      def method_missing(name, *args, &blk)
        @events[name] = [args, blk]
      end
    end

    describe Mapping do
      it "converts to a proc" do
        mapping = Mapping.new(:foo, :bar)
        context = TestRecorder.new(mapping)
        context.exec
        context.events.should == { bar: [[], nil] }
      end
    end
  end
end
