require 'bundler'
Bundler.setup

require 'simplecov'

require 'rspec'
require 'stepping_stone'
require 'text_mapper'
require 'text_mapper/support/listener_spec'

RSpec.configure do |config|
  module CucumberHelpers
    def inst(name, *pattern)
      SteppingStone::Model::Instruction.new(name, pattern)
    end
  end

  config.include(CucumberHelpers)
end
