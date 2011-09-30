require 'spec_helper'

module SteppingStone
  module Model
    describe Executor do
      let(:server) { double("sut server") }
      subject { Executor.new(server) }

      def scr(*actions)
        Script.new(TestCase.new("test case", *actions))
      end

      class FakeSession
        attr_reader :log, :action_to_status

        def initialize
          @log = EventLog.new
          @action_to_status = {
            :pass      => :passed,
            :fail      => :failed,
            :undefined => :undefined
          }
        end

        def perform(request)
          log.add(Response.new(request, Result.new(status_for(request.arguments))))
        end

        def events
          log.events.map(&:event)
        end

        def statuses
          log.history.map(&:status)
        end

        private

        def status_for(action)
          action_to_status.fetch(action, :undefined)
        end
      end

      describe "#execute" do
        let(:session) { FakeSession.new }

        it "triggers the events in the proper order" do
          script = scr(:pass, :pass)
          server.should_receive(:start_test).and_yield(session)
          subject.execute(script)
          session.events.should eq([:setup, :map, :map, :teardown])
        end

        it "executes passing actions" do
          server.should_receive(:start_test).and_yield(session)
          subject.execute(scr(:pass, :pass))
          session.statuses.should eq([:passed, :passed])
        end
      end
    end
  end
end
