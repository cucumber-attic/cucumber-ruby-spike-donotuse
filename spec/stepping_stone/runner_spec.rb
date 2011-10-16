require 'spec_helper'

module SteppingStone
  describe Runner do
    let(:server) { double("sut server") }
    subject { Runner.new(server) }

    def tc(*instructions)
      Model::TestCase.new("test case", *instructions)
    end

    class FakeSession
      attr_reader :log, :instruction_to_status

      def initialize
        @log = EventLog.new
        @instruction_to_status = {
          :pass      => :passed,
          :fail      => :failed,
          :undefined => :undefined
        }
      end

      def perform(request)
        log.add(Model::Response.new(request, Model::Result.new(status_for(request.arguments))))
      end

      def events
        log.events.map(&:event)
      end

      def statuses
        log.history.map(&:status)
      end

      private

      def status_for(instruction)
        instruction_to_status.fetch(instruction, :undefined)
      end
    end

    describe "#execute" do
      let(:session) { FakeSession.new }

      it "triggers the events in the proper order" do
        test_case = tc(:pass, :pass)
        server.should_receive(:start_test).and_yield(session)
        subject.execute(test_case)
        session.events.should eq([:setup, :map, :map, :teardown])
      end

      it "executes passing instructions" do
        server.should_receive(:start_test).and_yield(session)
        subject.execute(tc(:pass, :pass))
        session.statuses.should eq([:passed, :passed])
      end
    end
  end
end
