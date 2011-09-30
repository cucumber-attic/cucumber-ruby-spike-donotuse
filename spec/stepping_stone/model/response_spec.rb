require 'spec_helper'

module SteppingStone
  module Model
    describe Response do
      let(:passed) { Result.new(:passed) }
      let(:failed) { Result.new(:failed) }
      let(:undefined) { Result.new(:undefined) }
      let(:skipped) { Result.new(:skipped) }

      context "to a request that is not required" do
        let(:request) { Request.new(:setup, []) }

        context "with an undefined result" do
          subject { Response.new(request, undefined) }
          it { should_not be_important }
          its(:halt?) { should be_false }
          its(:to_s) { should eq("") }
        end

        context "with a failed result" do
          subject { Response.new(request, failed) }
          it { should be_important }
          its(:halt?) { should be_true }
          its(:to_s) { should eq("") }
        end
      end

      context "to a required request" do
        let(:request) { Request.required(:map, []) }

        context "with a passed result" do
          subject { Response.new(request, passed) }

          it { should be_passed }
          it { should_not be_failed }
          it { should_not be_undefined }
          it { should_not be_skipped }
          it { should be_important }

          its(:halt?) { should be_false }
          its(:to_s)  { should eq(".") }
        end

        context "with a failed result" do
          subject { Response.new(request, failed) }

          it { should be_failed }
          it { should_not be_passed }
          it { should_not be_undefined }
          it { should_not be_skipped }
          it { should be_important }

          its(:halt?) { should be_true }
          its(:to_s)  { should eq("F") }
        end

        context "with an undefined result" do
          subject { Response.new(request, undefined) }

          it { should be_undefined }
          it { should_not be_passed }
          it { should_not be_failed }
          it { should_not be_skipped }
          it { should be_important }

          its(:halt?) { should be_true }
          its(:to_s)  { should eq("U") }
        end

        context "with a skipped result" do
          subject { Response.new(request, skipped) }

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
