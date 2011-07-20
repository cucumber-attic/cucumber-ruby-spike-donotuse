require 'spec_helper'

module SteppingStone
  module Model
    describe Event do
      it "says if it passed" do
        Event.new([:from], :passed).should be_passed
      end
    end
  end
end
