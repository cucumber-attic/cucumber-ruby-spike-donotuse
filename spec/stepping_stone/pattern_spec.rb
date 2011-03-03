require 'spec_helper'

module SteppingStone
  describe Pattern do
    context 'matching "blargle"' do
      subject { Pattern.new("blargle") }

      it { should match("blargle") }
      it { should_not match("fooble") }
    end

    context 'matching "/argle$/"' do
      subject { Pattern.new(/argle$/) }
      
      it { should match("blargle") }
      it { should match("flargle") }
      it { should_not match("fooble") }
    end

    context 'matching String instances' do
      subject { Pattern.new(String) } 

      it { should match("blargle") }
      it { should match("") }
      it { should_not match(:blargle) }
      it { should_not match(["fooble"]) }
    end
  end
end
