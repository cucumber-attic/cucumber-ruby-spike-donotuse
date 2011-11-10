require 'spec_helper'

module SteppingStone
  module Model
    describe RunResult do
      let(:time) { Time.now }

      it "records the start time" do
        Timecop.freeze(time) { subject.start_run }
        subject.started_at.should == time
      end

      it "records the end time" do
        Timecop.freeze(time) { subject.end_run }
        subject.ended_at.should == time
      end

      it "says what the run duration is" do
        t1 = Time.now
        Timecop.freeze(t1)
        subject.start_run

        t2 = t1 + 10
        Timecop.freeze(t2)
        subject.end_run

        subject.duration.should eq(t2 - t1)
        Timecop.return
      end

      it "builds test case results from events"
      it "fails if it cannot build a complete test case"
      it "tells you the run's status"
      it "counts test cases"
      it "counts instructions"
    end
  end
end
