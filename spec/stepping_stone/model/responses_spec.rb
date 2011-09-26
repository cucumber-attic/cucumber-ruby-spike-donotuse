require 'spec_helper'

module SteppingStone
  module Model
    describe "response types" do
      let(:passed) { Result.new(:passed) }
      let(:failed) { Result.new(:failed) }
      let(:undefined) { Result.new(:undefined) }
      let(:skipped) { Result.new(:skipped) }

      describe Response do
        context "when undefined" do
          subject { Response.new(:setup, :name, undefined) }
          it { should_not be_important }
          its(:halt?) { should be_false }
          its(:to_s) { should eq("") }
        end

        context "when failed" do
          subject { Response.new(:setup, :name, failed) }
          it { should be_important }
          its(:halt?) { should be_true }
          its(:to_s) { should eq("") }
        end
      end

      describe ActionResponse do
        context "when passed" do
          subject { ActionResponse.new(:apply, :from, passed) }

          it { should be_passed }
          it { should_not be_failed }
          it { should_not be_undefined }
          it { should_not be_skipped }
          it { should be_important }

          its(:halt?) { should be_false }
          its(:to_s)  { should eq(".") }
        end

        context "when failed" do
          subject { ActionResponse.new(:apply, :from, failed) }

          it { should be_failed }
          it { should_not be_passed }
          it { should_not be_undefined }
          it { should_not be_skipped }
          it { should be_important }

          its(:halt?) { should be_true }
          its(:to_s)  { should eq("F") }
        end

        context "when undefined" do
          subject { ActionResponse.new(:apply, :from, undefined) }

          it { should be_undefined }
          it { should_not be_passed }
          it { should_not be_failed }
          it { should_not be_skipped }
          it { should be_important }

          its(:halt?) { should be_true }
          its(:to_s)  { should eq("U") }
        end

        context "when skipped" do
          subject { ActionResponse.new(:apply, :from, skipped) }

          it { should be_skipped }
          it { should_not be_passed }
          it { should_not be_failed }
          it { should_not be_undefined }
          it { should be_important }

          its(:halt?) { should be_true }
          its(:to_s) { should eq("S") }
        end
      end
    end
  end
end
