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

        def handle(request)
          log.add(Response.new(request.event, request.action, Result.new(status_for(request.action))))
        end

        def types
          log.events.map(&:type)
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
          script = scr(:action1, :action2)
          server.should_receive(:start_test).and_yield(session)
          subject.execute(script)
          session.types.should eq([:setup,
                                   :before_apply, :apply, :after_apply,
                                   :before_apply, :apply, :after_apply,
                                   :teardown])
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
