require 'spec_helper'

module SteppingStone
  describe Configuration do
    subject { SteppingStone.configuration }

    def configure(&config)
      SteppingStone.configure(&config)
    end

    describe "#global" do
      it "holds global options for convenience" do
        configure do |config|
          config.global[:bag_of_holding] = true
        end

        subject.global[:bag_of_holding].should be_true
      end
    end

    describe "#compiler" do
      it "defaults to the gherkin compiler" do
        subject.compiler.should be(:gherkin)
      end
    end

    describe "#server" do
      it "defaults to the text_mapper server" do
        subject.server.should be(:text_mapper)
      end
    end
  end
end
