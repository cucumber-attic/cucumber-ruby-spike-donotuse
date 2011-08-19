require 'spec_helper'

module SteppingStone
  module Model
    describe EventLog do
      before do
        subject.add(ev(:setup, :passed))
        subject.add(ev(:before_apply, :undefined))
        subject.add(action(:apply, :passed))
        subject.add(ev(:after_apply, :undefined))
        subject.add(ev(:teardown, :passed))
      end

      def ev(type, status)
        Events.send(type, :name, status)
      end

      def action(type, status)
        Events::ActionEvent.new(type, :name, res(status))
      end

      def res(status)
        Result.new(status)
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

      it "creates a table of executed events" do
        subject.executed_events.should eq([
          [:setup, [:name], :passed],
          [:apply, [:name], :passed],
          [:teardown, [:name], :passed]
        ])
      end

      it "builds a string representation" do
        subject.to_s.should eq(".")
      end

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
