require 'spec_helper'

module SteppingStone
  module Model
    describe Executor do
      let(:server) { double("sut server") }
      subject { Executor.new(server) }

      def tc(*actions)
        TestCase.new("test case", *actions)
      end

      class FakeSession
        attr_reader :log, :action_to_status

        def initialize(action_to_status={})
          @log = EventLog.new
          @action_to_status = {
            :pass      => :passed,
            :fail      => :failed,
            :undefined => :undefined
          }.merge(action_to_status)
        end

        def setup
          log.add(Response.new(:setup, :name, Result.new(status_for(:setup))))
        end

        def teardown
          log.add(Response.new(:teardown, :name, Result.new(:passed)))
        end

        def before_apply(action)
          log.add(Response.new(:before_apply, :name, Result.new(:undefined)))
        end

        def after_apply(action)
          log.add(Response.new(:after_apply, :name, Result.new(:undefined)))
        end

        def apply(action)
          log.add(Response.new(:apply, action, Result.new(status_for(action))))
        end

        def types
          log.events.map(&:type)
        end

        def statuses
          log.history.map(&:status)
        end

        private

        def status_for(action)
          action_to_status.fetch(action, :passed)
        end
      end

      describe "#execute" do
        let(:session) { FakeSession.new }

        it "triggers the events in the proper order" do
          test_case = tc(:action1, :action2)
          server.should_receive(:start_test).with(test_case).and_yield(session)
          subject.execute(test_case)
          session.types.should eq([:setup,
                                   :before_apply, :apply, :after_apply,
                                   :before_apply, :apply, :after_apply,
                                   :teardown])
        end

        it "executes passing actions" do
          server.should_receive(:start_test).and_yield(session)
          subject.execute(tc(:pass, :pass))
          session.statuses.should eq([:passed, :passed, :passed, :passed])
        end
      end
    end
  end
end
