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
        attr_reader :log, :responder, :action_to_status

        def initialize(action_to_status={})
          @log = EventLog.new
          @responder = Responder.new
          @action_to_status = {
            :pass      => :passed,
            :fail      => :failed,
            :undefined => :undefined
          }.merge(action_to_status)
        end

        def setup
          log.add(responder.setup(:name, Result.new(status_for(:setup))))
        end

        def teardown
          log.add(responder.teardown(:name, Result.new(:passed)))
        end

        def before_apply(action)
          log.add(responder.before_apply(:name, Result.new(:undefined)))
        end

        def after_apply(action)
          log.add(responder.after_apply(:name, Result.new(:undefined)))
        end

        def apply(action)
          log.add(responder.apply(action, Result.new(status_for(action))))
        end

        def skip(action)
          log.add(responder.skip(action, Result.new(:skipped)))
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

        it "skips actions after a failing action" do
          server.should_receive(:start_test).and_yield(session)
          subject.execute(tc(:pass, :fail, :pass))
          session.statuses.should eq([:passed, :passed, :failed, :skipped])
        end

        it "skips actions after an undefined action" do
          server.should_receive(:start_test).and_yield(session)
          subject.execute(tc(:pass, :undefined, :pass))
          session.statuses.should eq([:passed, :passed, :undefined, :skipped])
        end

        context "when setup fails" do
          let(:session) { FakeSession.new(:setup => :failed) }

          it "skips the actions that follow it" do
            server.should_receive(:start_test).and_yield(session)
            subject.execute(tc(:pass, :pass))
            session.statuses.should eq([:failed, :skipped, :skipped])
          end
        end
      end
    end
  end
end
