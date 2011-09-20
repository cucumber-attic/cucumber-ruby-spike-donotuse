require 'stepping_stone'
require 'rspec/expectations'

SteppingStone.configure do |config|
  config.before do
    puts "Before"
  end

  config.before do
    puts "Before 2"
  end

  config.before("~@foo") do
    puts "Before ~@foo"
  end

  config.after do
    puts "After"
  end

  config.after("@foo") do
    puts "After @foo"
  end

  config.around do |scenario|
    puts "Around: starting"
    scenario.call
    puts "Around: ending"
  end
end
