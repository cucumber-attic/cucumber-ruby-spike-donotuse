require 'spec_helper'

module SteppingStone
  module Model
    module Events
      # TODO: Extract state specs into spec of parent Event class
      #       Rename #skip? to #skip_remaining_actions?

      describe ActionEvent do
        context "when passed" do
          subject { ActionEvent.new(:apply, :from, :passed) }

          it { should be_passed }
          it { should_not be_failed }
          it { should_not be_undefined }
          it { should_not be_skipped }

          its(:skip?) { should be_false }
          its(:to_s)  { should eq(".") }
        end

        context "when failed" do
          subject { ActionEvent.new(:apply, :from, :failed) }

          it { should be_failed }
          it { should_not be_passed }
          it { should_not be_undefined }
          it { should_not be_skipped }

          its(:skip?) { should be_true }
          its(:to_s)  { should eq("F") }
        end

        context "when undefined" do
          subject { ActionEvent.new(:apply, :from, :undefined) }

          it { should be_undefined }
          it { should_not be_passed }
          it { should_not be_failed }
          it { should_not be_skipped }

          its(:skip?) { should be_true }
          its(:to_s)  { should eq("U") }
        end

        context "when skipped" do
          subject { ActionEvent.new(:apply, :from, :skipped) }

          it { should be_skipped }
          it { should_not be_passed }
          it { should_not be_failed }
          it { should_not be_undefined }

          its(:to_s) { should eq("S") }
        end
      end

      describe HookEvent do
        context "when undefined" do
          subject { HookEvent.new(:setup, :name, :undefined) }
          its(:skip?) { should be_false }
          its(:to_s) { should eq("") }
        end

        context "when failed" do
          subject { HookEvent.new(:setup, :name, :failed) }
          its(:skip?) { should be_true }
          its(:to_s) { should eq("") }
        end
      end
    end
  end
end
