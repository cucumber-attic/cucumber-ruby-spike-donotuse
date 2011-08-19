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
        attr_reader :events, :action_to_status

        def initialize(action_to_status={})
          @events = EventLog.new
          @action_to_status = {
            :pass      => :passed,
            :fail      => :failed,
            :undefined => :undefined
          }.merge(action_to_status)
        end

        def setup
          events.add(Events.setup(:name, Result.new(status_for(:setup))))
        end

        def teardown
          events.add(Events.teardown(:name, Result.new(:passed)))
        end

        def before_apply(action)
          events.add(Events.before_apply(:name, Result.new(:undefined)))
        end

        def after_apply(action)
          events.add(Events.after_apply(:name, Result.new(:undefined)))
        end

        def apply(action)
          events.add(Events.apply(action, Result.new(status_for(action))))
        end

        def skip(action)
          events.add(Events.skip(action, Result.new(:skipped)))
        end

        def types
          events.types
        end

        def statuses
          events.statuses
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

        it "skips actions after a failing action" do
          server.should_receive(:start_test).and_yield(session)
          subject.execute(tc(:pass, :fail, :pass))
          session.statuses.should eq([:passed, :passed, :failed, :skipped, :passed])
        end

        it "skips actions after an undefined action" do
          server.should_receive(:start_test).and_yield(session)
          subject.execute(tc(:pass, :undefined, :pass))
          session.statuses.should eq([:passed, :passed, :undefined, :skipped, :passed])
        end

        context "when setup fails" do
          let(:session) { FakeSession.new(:setup => :failed) }

          it "skips the actions that follow it" do
            server.should_receive(:start_test).and_yield(session)
            subject.execute(tc(:pass, :pass))
            session.statuses.should eq([:failed, :skipped, :skipped, :passed])
          end
        end
      end
    end
  end
end
