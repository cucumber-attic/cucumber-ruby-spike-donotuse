require 'spec_helper'

module SteppingStone
  module Model
    describe Event do
      it "is a value equal to its status, though this should probably change in the future" do
        Event.new([:from], :passed).should eq(:passed)
      end
    end
  end
end
