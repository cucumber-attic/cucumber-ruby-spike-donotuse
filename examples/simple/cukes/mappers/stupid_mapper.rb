require 'cukes_helper'

module StupidMapper
  extend SteppingStone::Mapper

  map("a foo").to(:foo)
  map(/a "(\w+)" with:/, DocString).to(:go)

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

  def foo
    puts "In Foo"
  end

  def go(name, string)
    puts name
    puts string
  end
end

