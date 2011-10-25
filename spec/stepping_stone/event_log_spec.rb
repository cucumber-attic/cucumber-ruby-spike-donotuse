require 'spec_helper'

module SteppingStone
  describe EventLog do
    def ev(event, status)
      Model::Result.new(status, nil, Model::Instruction.new(event, []))
    end

    before do
      subject.add(ev(:setup, :passed))
      subject.add(ev(:map, :passed))
      subject.add(ev(:map, :undefined))
      subject.add(ev(:map, :skipped))
      subject.add(ev(:teardown, :failed))
    end

    describe "#events" do
      it "includes all events" do
        subject.should have(5).events
      end

      it "filters events" do
        subject.events(status: :passed).length.should eq(2)
        subject.events(event: :map).length.should eq(3)
      end
    end

    describe "#history" do
      it "includes important events" do
        subject.history.should have(5).events
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
      let(:event) { Model::Result.new(:passed, nil, Model::Instruction.new(:event, [])) }

      it "adds the event to the log" do
        subject.add(event)
        subject.events.should include(event)
      end
    end

    describe "#each" do
      it "iterates through all the events" do
        events = []
        subject.each { |e| events << e }
        events.map(&:event).should eq([:setup, :map, :map, :map, :teardown])
      end
    end
  end
end
