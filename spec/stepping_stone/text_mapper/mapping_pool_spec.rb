require 'spec_helper'

module SteppingStone
  module TextMapper
    describe MappingPool do
      subject { MappingPool.new }

      let(:mapping) { Mapping.new(:foo, :bar) }

      describe "#find" do
        it "returns nil" do
          subject.find([:foo]).should eq(nil)
        end
      end

      describe "#find!" do
        it "raises UndefinedMappingError" do
          expect {
            subject.find!([:foo])
          }.to raise_error(UndefinedMappingError)
        end
      end

      describe "#add" do
        it "adds the mapping to the pool" do
          subject.add(mapping)
          subject.mappings.should eq([mapping])
        end
      end

      context "with mappings" do
        subject { MappingPool.new(mapping) }

        describe "#find" do
          it "returns the matching mapping" do
            subject.find([:foo]).should eq(mapping)
          end

          it "returns nil if no mapping matches" do
            subject.find([:bar]).should eq(nil)
          end
        end
      end
    end
  end
end
