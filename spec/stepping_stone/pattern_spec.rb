require 'spec_helper'

module SteppingStone
  describe Pattern, 'matching "blargle"' do
    subject { Pattern.new("blargle") }

    it { should match("blargle") }
    it { should_not match("fooble") }
  end

  describe Pattern, 'matching "/argle$/" against' do
    subject { Pattern.new(/argle$/) }
    
    it { should match("blargle") }
    it { should match("flargle") }
    it { should_not match("fooble") }
  end
end
