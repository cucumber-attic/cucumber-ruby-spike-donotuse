require 'spec_helper'

module SteppingStone
  describe TextMapper do
    def build_mapper(name)
      from = :"from_#{name}"
      to   = :"to_#{name}"

      Module.new do
        extend TextMapper
        def_map from => to
        define_method(to) { to }
      end
    end

    context "with one mapper" do
      before { build_mapper(:mapper_a) }

      describe "#all_mappings" do
        it "exports mappings" do
          subject.all_mappings.collect(&:name).should == [:from_mapper_a]
        end
      end

      it "exports the helper module"
      it "exports hooks"
    end

    context "with many mappers" do
      it "exports mappings"
      it "exports the helper module"
      it "exports hooks"
    end
  end
end
