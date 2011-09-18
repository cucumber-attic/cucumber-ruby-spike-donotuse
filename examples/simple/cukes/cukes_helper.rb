require 'stepping_stone'
require 'rspec/expectations'

SteppingStone.configure do |config|
  config.before do
    puts "Before"
  end

  config.after do
    puts "After"
  end

  config.around do |scenario|
    puts "Around: starting"
    scenario.call
    puts "Around: ending"
  end
end
