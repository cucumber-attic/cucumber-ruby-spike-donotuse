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
          @events << :setup
        end

        def teardown
          @events << :teardown
        end

        def apply(action)
          @events << action
          action
        end
      end

      describe "#execute" do
        let(:session) { FakeSession.new }

        it "executes the test case" do
          test_case = build_tc(:one, :two)
          server.should_receive(:start_test).with(test_case).and_yield(session)
          subject.execute(test_case)
          session.events.should eq([:setup, :one, :two, :teardown])
        end

        it "stops executing when an action fails" do
          server.should_receive(:start_test).and_yield(session)
          subject.execute(build_tc(:fail, :pass))
          session.events.should eq([:setup, :fail, :teardown])
        end
      end
    end
  end
end
