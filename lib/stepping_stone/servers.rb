require 'stepping_stone/servers/rb'

module SteppingStone
  module Servers
    def self.boot!(name=:default)
      case name
      when :default
        Rb.boot!
      else
        fail "No server named #{name} has been registered!"
      end
    end
  end
end
