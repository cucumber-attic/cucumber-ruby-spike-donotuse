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
        attr_reader :events

        def initialize
          @events = []
        end

        def setup
          @events << Event.new(:setup, :passed)
        end

        def teardown
          @events << Event.new(:teardown, :passed)
        end

        def apply(action)
          event = Event.new(action, action)
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
          subject.execute(build_tc(:passed, :passed))
          session.statuses.should eq([:passed, :passed, :passed, :passed])
        end

        it "skips actions after a failing action" do
          server.should_receive(:start_test).and_yield(session)
          subject.execute(build_tc(:failed, :passed))
          session.statuses.should eq([:passed, :failed, :skipped, :passed])
        end
      end
    end
  end
end
