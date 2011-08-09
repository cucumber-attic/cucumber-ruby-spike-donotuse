require 'spec_helper'

module SteppingStone
  module Model
    describe EventLog do
      before do
        subject.add(ev(:setup, :passed))
        subject.add(ev(:before_apply, :undefined))
        subject.add(ev(:apply, :passed))
        subject.add(ev(:after_apply, :undefined))
        subject.add(ev(:teardown, :passed))
      end

      def ev(type, status)
        Events.send(type, :name, status)
      end

      it "creates a list of event types" do
        subject.types.should eq(
          [:setup, :before_apply, :apply, :after_apply, :teardown]
        )
      end

      it "creates a list of executed event statuses" do
        subject.statuses.should eq(
          [:passed, :passed, :passed]
        )
      end

      it "builds a string representation"

      describe "#add" do
        let(:event) { Events.apply(:from, :passed) }

        it "adds the event to the log" do
          subject.add(event)
          subject.events.should include(event)
        end

        it "returns the event" do
          subject.add(event).should eq(event)
        end
      end
    end
  end
end
