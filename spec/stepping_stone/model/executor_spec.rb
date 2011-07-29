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
          @events = []
          @action_to_status = {
            :pass      => :passed,
            :fail      => :failed,
            :undefined => :undefined
          }.merge(action_to_status)
        end

        def setup
          # Event.hook([:setup, test_case], status_for(:setup))
          event = Event.new(:setup, :name, status_for(:setup))
          @events << event
          event
        end

        def teardown
          @events << Event.new(:teardown, :name, :passed)
        end

        def before_apply(action)
          event = Event.new(:before_apply, :name, :no_op)
          @events << event
          event
        end

        def after_apply(action)
          event = Event.new(:after_apply, :name, :no_op)
          @events << event
          event
        end

        def apply(action)
          event = Event.new(:apply, action, status_for(action))
          @events << event
          event
        end

        def skip(action)
          event = Event.new(:skip, action, :skipped)
          @events << event
          event
        end

        def types
          @events.map(&:type)
        end

        def statuses
          @events.reject(&:no_op?).map(&:status)
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
