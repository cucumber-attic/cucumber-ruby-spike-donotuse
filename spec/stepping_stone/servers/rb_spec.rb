require 'spec_helper'

module SteppingStone
  module Servers
    describe Rb do
      subject { Rb.new(Hooks.new) }

      describe "#start_test" do
        it "starts a new session"
        it "yields the new session to the given block"

        it "ends the session when invoked with a block" do
          subject.start_test(double("test_case", :tags => [])) do |session|
            session.should_receive(:end_test)
          end
        end
      end
    end
  end
end
