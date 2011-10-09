require 'cukes_helper'

module StupidMapper
  extend SteppingStone::Mapper

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

