require 'spec_helper'

module SteppingStone
  module Model
    describe RunResult do
      describe "start and stop time" do
        let(:t1) { Time.now }
        let(:t2) { t1 + 10 }

        after do
          Timecop.return
        end

        it "records the start time" do
          Timecop.freeze(t1) { subject.start_run }
          subject.started_at.should == t1
        end

        it "records the end time" do
          Timecop.freeze(t1) { subject.end_run }
          subject.ended_at.should == t1
        end

        it "says what the run duration is" do
          Timecop.freeze(t1)
          subject.start_run

          Timecop.freeze(t2)
          subject.end_run

          subject.duration.should eq(t2 - t1)
        end
      end

      it "counts the number of results" do
        subject.add(double("test case result"))
        subject.add(double("test case result"))
        subject.result_count.should eq(2)
      end

      describe "#status_of" do
        it "finds the status of a particular result" do
          result = double("result", :id => "foo")
          result.should_receive(:status).and_return(:failed)
          subject.add(result)
          subject.status_of("foo").should eq(:failed)
        end

        it "returns nil if no status can be found" do
          subject.status_of("does not exist").should be(nil)
        end
      end

      describe "#status" do
        let(:passed)    { double("result", :status => :passed) }
        let(:failed)    { double("result", :status => :failed) }
        let(:undefined) { double("result", :status => :undefined) }

        it "says when the run is passed" do
          subject.add(undefined)
          subject.add(passed)
          subject.status.should eq(:passed)
        end

        it "says when the run is failed" do
          subject.add(failed)
          subject.add(passed)
          subject.add(undefined)
          subject.status.should eq(:failed)
        end
      end
    end
  end
end
