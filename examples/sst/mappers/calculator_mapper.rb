require 'sst_helper'

module CalculatorMapper
  extend SteppingStone::Mapper

  def_map "a foo" => :foo
  def_map [/a "(\w+)" with:/, DocString] => :go

  def foo
    puts "In Foo"
  end

  def go(name, string)
    puts name
    puts string
  end
end

