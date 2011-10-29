require 'cukes_helper'

module StupidMapper
  extend SteppingStone::Mapper

  before do
    puts "I AM A BEFORE HOOK!"
  end

  after do
    puts "I AM AN AFTER HOOK!"
  end

  around do |continue|
    puts "AND I AM RUNNING AROUND!"
    continue.call
    puts "(NOW IT'S AFTER THE SCENARIO!)"
  end

  before do
    puts "Before"
  end

  before do
    puts "Before 2"
  end

  before("~@foo") do
    puts "Before ~@foo"
  end

  after do
    puts "After"
  end

  after("@foo") do
    puts "After @foo"
  end

  around do |scenario|
    puts "Around: starting"
    scenario.call
    puts "Around: ending"
  end

  map("a foo").to(:foo)
  map(/a "(\w+)" with:/, DocString).to(:go)

  def foo
    puts "In Foo"
  end

  def go(name, string)
    puts name
    puts string
  end
end

