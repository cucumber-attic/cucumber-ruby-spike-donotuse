require 'spec_helper'

module SteppingStone
  module Model
    describe EventLog do
      let(:responder) { Responder.new }

      def ev(type, status)
        responder.send(type, :name, Result.new(status))
      end

      before do
        subject.add(ev(:setup, :passed))
        subject.add(ev(:before_apply, :undefined))
        subject.add(ev(:apply, :passed))
        subject.add(ev(:after_apply, :passed))
        subject.add(ev(:before_apply, :undefined))
        subject.add(ev(:apply, :undefined))
        subject.add(ev(:after_apply, :undefined))
        subject.add(ev(:before_apply, :undefined))
        subject.add(ev(:apply, :skipped))
        subject.add(ev(:after_apply, :undefined))
        subject.add(ev(:teardown, :failed))
      end

      describe "#events" do
        it "includes all events" do
          subject.should have(11).events
        end

        it "filters events" do
          subject.events(status: :passed).length.should eq(3)
          subject.events(type: :apply).length.should eq(3)
          subject.events(status: :undefined, type: :before_apply).length.should eq(3)
        end
      end

      describe "#history" do
        it "includes only the important events" do
          subject.history.should have(6).events
        end

        it "does not include undefined hooks" do
          subject.history.each do |event|
            if Events::HookEvent === event
              event.should_not be_undefined
            end
          end
        end
      end

      describe "#add" do
        let(:event) { responder.apply(:from, :passed) }

        it "adds the event to the log" do
          subject.add(event)
          subject.events.should include(event)
        end

        it "returns the event" do
          subject.add(event).should eq(event)
        end
      end

      describe "#to_s" do
        it "builds a string representation" do
          subject.to_s.should eq(".US")
        end
      end
    end
  end
end
