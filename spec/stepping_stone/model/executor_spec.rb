require 'spec_helper'

module SteppingStone
  module Model
    describe Executor do
      let(:server) { double("sut server") }
      subject { Executor.new(server) }

      def build_tc(*actions)
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
          event = Event.new(:setup, status_for(:setup))
          @events << event
          event
        end

        def teardown
          @events << Event.new(:teardown, :passed)
        end

        def apply(action)
          event = Event.new(action, status_for(action))
          @events << event
          event
        end

        def skip(action)
          event = Event.new(action, :skipped)
          @events << event
          event
        end

        def names
          @events.map(&:name)
        end

        def statuses
          @events.map(&:status)
        end

        private

        def status_for(action)
          action_to_status.fetch(action, :passed)
        end
      end

      describe "#execute" do
        let(:session) { FakeSession.new }

        it "executes the test case" do
          test_case = build_tc(:action1, :action2)
          server.should_receive(:start_test).with(test_case).and_yield(session)
          subject.execute(test_case)
          session.names.should eq([:setup, :action1, :action2, :teardown])
        end

        it "executes passing actions" do
          server.should_receive(:start_test).and_yield(session)
          subject.execute(build_tc(:pass, :pass))
          session.statuses.should eq([:passed, :passed, :passed, :passed])
        end

        it "skips actions after a failing action" do
          server.should_receive(:start_test).and_yield(session)
          subject.execute(build_tc(:pass, :fail, :pass))
          session.statuses.should eq([:passed, :passed, :failed, :skipped, :passed])
        end

        it "skips actions after an undefined action" do
          server.should_receive(:start_test).and_yield(session)
          subject.execute(build_tc(:pass, :undefined, :pass))
          session.statuses.should eq([:passed, :passed, :undefined, :skipped, :passed])
        end

        context "when setup fails" do
          let(:session) { FakeSession.new(:setup => :failed) }

          it "skips the actions that follow it" do
            server.should_receive(:start_test).and_yield(session)
            subject.execute(build_tc(:pass, :pass))
            session.statuses.should eq([:failed, :skipped, :skipped, :passed])
          end
        end
      end
    end
  end
end
