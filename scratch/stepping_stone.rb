require 'rspec/expectations'

module StepMapper
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def mappings
      @mappings ||= {}
    end

    def def_map(mapping)
      regex, meth_name = mapping.shift
      arg_types        = mapping[:args] || []
      name_types       = regex.names

      all_types = name_types.inject(arg_types) do |acc, name_type|
        real_type = const_get(name_type.capitalize)
        acc.unshift(real_type)
      end

      mappings[regex]  = [meth_name, all_types]
    end
  end

  def dispatch(action)
    from, to             = mappings.find{ |regex, _| action =~ regex }
    meth_name, arg_types = to
    captures             = from.match(action).captures

    arguments = if !arg_types.empty?
      captures.zip(arg_types).collect do |capture, type|
        if type == Integer
          capture.to_i
        else
          type.new(capture)
        end
      end
    else
      captures
    end

    send(meth_name, *arguments)
  end

  def mappings
    self.class.mappings
  end
end

class Calculator
  attr_reader :status

  def initialize
    @status = 0
  end

  def add(n, m)
    @status += n + m
  end
end

class CalculatorMapping
  include StepMapper

  def_map /a calculator/                  => :create_calculator
  def_map /I add (\d+) and (\d+)/         => :add, args: [Integer, Integer]
  def_map /the result is (?<integer>\d+)/ => :result

  def create_calculator
    @calculator = Calculator.new
  end

  def add(n, m)
    @calculator.add(n, m)
  end

  def result(result)
    @calculator.status.should == result
  end
end

t = CalculatorMapping.new
t.dispatch("a calculator")
t.dispatch("I add 4 and 5")
t.dispatch("the result is 9")
t.dispatch("the result is 10")
