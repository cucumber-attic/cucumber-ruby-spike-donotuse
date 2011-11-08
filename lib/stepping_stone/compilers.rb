require 'stepping_stone/compilers/gherkin'

module SteppingStone
  # A compilers's responsibility is to convert formatted 
  # input into Cucumber test cases.
  module Compilers
    def self.boot!(name=:default, opts={})
      case name
      when :default, :gherkin
        Gherkin.boot!(opts)
      else
        fail "No compiler for '#{name}' has been registered!"
      end
    end
  end
end
