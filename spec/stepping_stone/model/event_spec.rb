require 'spec_helper'

module SteppingStone
  module Model
    describe Event, "resulting from an action (like apply)" do
      context "when passed" do
        subject { Event.new(:apply, [:from], :passed) }

        it { should be_passed }
        it { should_not be_failed }
        it { should_not be_undefined }

        its(:skip?) { should be_false }
      end

      context "when failed" do
        subject { Event.new(:apply, [:from], :failed) }

        it { should be_failed }
        it { should_not be_passed }
        it { should_not be_undefined }

        its(:skip?) { should be_true }
      end

      context "when undefined" do
        subject { Event.new(:apply, [:from], :undefined) }

        it { should be_undefined }
        it { should_not be_passed }
        it { should_not be_failed }

        its(:skip?) { should be_true }
      end
    end

    describe Event, "resulting from a hook (like setup)" do
      context "when undefined" do
        subject { Event.new(:setup, [:name], :undefined) }
        its(:skip?) { should be_false }
      end
    end
  end
end
