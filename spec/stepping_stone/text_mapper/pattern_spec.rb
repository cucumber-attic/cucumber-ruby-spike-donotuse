require 'spec_helper'

module SteppingStone
  module TextMapper
    describe Pattern do
      describe "#match" do
        context 'matching "blargle"' do
          subject { Pattern.new(["blargle"]) }

          it { should match(["blargle"]) }
          it { should_not match(["fooble"]) }
          it { should_not match("blargle") }
          it { should_not match([]) }
        end

        context 'matching "/argle$/"' do
          subject { Pattern[/argle$/] }

          it { should match(["blargle"]) }
          it { should match(["flargle"]) }
          it { should_not match("blargle") }
          it { should_not match("fooble") }
        end

        context 'matching [1,2,3]' do
          subject { Pattern.new([[1,2,3]]) }

          it { should match([[1,2,3]]) }
          it { should_not match([]) }
          it { should_not match([1,2,3]) }
          it { should_not match([[1,2,3,4]]) }
          it { should_not match("fooble") }
          it { should_not match([1,[2],[[3]]]) }
        end

        context 'matching String instances' do
          subject { Pattern.new([String]) }

          it { should match(["blargle"]) }
          it { should match([""]) }
          it { should_not match("blargle") }
          it { should_not match([:blargle]) }
          it { should_not match([]) }
        end

        context 'matching Array instances' do
          subject { Pattern.new([Array]) }

          it { should match([[1, 2, 3]]) }
          it { should match([[]]) }
          it { should_not match(["string"]) }
          it { should_not match([:symbol]) }
          it { should_not match([]) }
        end

        context 'matching "hello", /(world|universe)/' do
          subject { Pattern.new(["hello", /(world|universe)/]) }

          it { should match(["hello", "world"]) }
          it { should match(["hello", "universe"]) }
          it { should_not match(["hell", "world"]) }
          it { should_not match(["hello", "moon"]) }
          it { should_not match(["goodnight", "world"]) }
        end

        context 'matching Class, :sym, [1,2,3]' do
          subject { Pattern[Class, :sym, [1,2,3]] }
          let(:constant) { Constant = 2112; Constant }

          it { should match([String, :sym, [1,2,3]]) }
          it { should_not match([Array, :sym, [1,2]]) }
          it { should_not match([Module, :method, [1,2,3]]) }
          it { should_not match([constant, :sym, [1,2,3]]) }
        end
      end

      describe "#===" do
        subject { Pattern[:abc] }

        it "returns true when there is a match" do
          subject.===([:abc]).should be(true)
        end

        it "returns false when there is not a match" do
          subject.===([:def]).should be(false)
        end
      end
    end
  end
end
