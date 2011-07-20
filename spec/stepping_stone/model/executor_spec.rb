require 'spec_helper'

module SteppingStone
  module Model
    describe Executor do
      let(:server) { double("sut server") }
      subject { Executor.new(server) }

      describe "#execute" do
        def build_tc(*actions)
          TestCase.new("test case", *actions)
        end

        class TestSession
          def apply(action)
            action
          end
        end

        let(:session) { TestSession.new }

        it "executes the test case" do
          test_case = build_tc("one", "two")
          server.should_receive(:start_test).with(test_case).and_yield(session)
          session.should_receive(:setup).ordered
          session.should_receive(:apply).with("one").ordered
          session.should_receive(:apply).with("two").ordered
          session.should_receive(:teardown).ordered
          subject.execute(test_case)
        end

        it "stops executing when an action fails" do
          test_case = build_tc(:fail, :pass)
          server.should_receive(:start_test).with(test_case).and_yield(session)
          session.should_receive(:setup).ordered
          session.stub(:apply) { |arg| arg }
          session.should_not_receive(:apply).with(:pass)
          session.should_receive(:teardown).ordered
          subject.execute(test_case)
        end

        class FakeSession
          attr_reader :actions

          def initialize
            @actions = []
          end

          def setup; end
          def teardown; end

          def apply(action)
            @actions << action
            action
          end
        end

        class FakeServer
          def initialize(session)
            @session = session
          end

          def start_test(test_case)
            yield @session
          end
        end

        it "executes with a fake session implementation" do
          sess = FakeSession.new
          serv = FakeServer.new(sess)
          executor = Executor.new(serv)
          test_case = build_tc(:fail, :pass)
          executor.execute(test_case)
          sess.actions.should eq([:fail])
        end
      end
    end
  end
end
