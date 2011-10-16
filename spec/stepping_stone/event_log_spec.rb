require 'spec_helper'

module SteppingStone
  describe EventLog do
    def ev(event, status)
      req = Model::Request.new(event, [])
      res = Model::Result.new(status)
      Model::Response.new(req, res)
    end

    before do
      subject.add(ev(:setup, :passed))
      subject.add(ev(:before_apply, :undefined))
      subject.add(ev(:map, :passed))
      subject.add(ev(:after_apply, :passed))
      subject.add(ev(:before_apply, :undefined))
      subject.add(ev(:map, :undefined))
      subject.add(ev(:after_apply, :undefined))
      subject.add(ev(:before_apply, :undefined))
      subject.add(ev(:map, :skipped))
      subject.add(ev(:after_apply, :undefined))
      subject.add(ev(:teardown, :failed))
    end

    describe "#events" do
      it "includes all events" do
        subject.should have(11).events
      end

      it "filters events" do
        subject.events(status: :passed).length.should eq(3)
        subject.events(event: :map).length.should eq(3)
        subject.events(status: :undefined, event: :before_apply).length.should eq(3)
      end
    end

    describe "#history" do
      it "includes important events" do
        subject.history.should have(6).events
        subject.history.each do |event|
          event.should be_important
        end
      end

      it "excludes unimportant events" do
        unimportant = ev(:setup, :undefined)
        subject.add(unimportant)
        subject.history.should_not include(unimportant)
      end
    end

    describe "#add" do
      let(:event) { Model::Response.new(Model::Request.new(:map, [:from]), Model::Result.new(:passed)) }

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
