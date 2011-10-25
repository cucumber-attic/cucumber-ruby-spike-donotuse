require 'spec_helper'

module SteppingStone
  describe Runner do
    let(:server) { double("sut server") }
    let(:reporter) { Reporter.new }
    let(:events)   { reporter.log.map(&:event) }
    let(:statuses) { reporter.history.map(&:status) }

    subject { Runner.new(server, reporter) }

    def tc(*instructions)
      Model::TestCase.new("test case", *instructions)
    end

    class FakeSession
      def initialize
        @instruction_to_status = {
          :pass      => :passed,
          :fail      => :failed,
          :undefined => :undefined
        }
      end

      def dispatch(request)
        response_for(request)
      end

      def response_for(request)
        Model::Result.new(status_for(request.arguments), nil, request)
      end

      def status_for(instruction)
        @instruction_to_status.fetch(instruction, :undefined)
      end
    end

    describe "#execute" do
      let(:session)  { FakeSession.new }

      before do
        server.should_receive(:start_test).and_yield(session)
      end

      it "send requests to the session" do
        subject.execute(tc(:pass, :pass))
        events.should eq([:setup, :map, :map, :teardown])
      end

      it "stops executing when an instruction fails" do
        subject.execute(tc(:pass, :fail, :pass))
        statuses.should eq([:passed, :failed, :skipped])
      end

      context "test case with failing setup"
      context "test case with failing teardown"      
      context "test case with undefined setup and teardown"
      context "test case with all steps passing"
      context "test case with an undefined step"
      context "test case with a failing step"
      context "test case with a pending step"
    end
  end
end
