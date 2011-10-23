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

      def perform(request)
        response_for(request)
      end

      def response_for(request)
        Model::Response.new(request, Model::Result.new(status_for(request.arguments)))
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

      it "send requests to the session in the proper order" do
        subject.execute(tc(:pass, :pass))
        events.should eq([:setup, :map, :map, :teardown])
      end

      it "stops executing when an instruction fails" do
        subject.execute(tc(:pass, :fail, :pass))
        statuses.should eq([:passed, :failed, :skipped])
      end
    end
  end
end
