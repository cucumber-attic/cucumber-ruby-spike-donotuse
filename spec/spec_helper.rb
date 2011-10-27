require 'bundler'
Bundler.setup

require 'rspec'
require 'stepping_stone'
require 'text_mapper'

RSpec.configure do |config|
  module CucumberHelpers
    def inst(name, *pattern)
      SteppingStone::Model::Instruction.new(name, pattern)
    end
  end

  config.include(CucumberHelpers)
end
