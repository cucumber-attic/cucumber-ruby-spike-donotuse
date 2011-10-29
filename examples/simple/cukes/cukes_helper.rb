require 'stepping_stone'
require 'rspec/expectations'

SteppingStone.configure do |config|
  config.global_opts[:foo] = "bar"
end
