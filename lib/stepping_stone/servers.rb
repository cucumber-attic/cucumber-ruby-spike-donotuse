require 'stepping_stone/servers/text_mapper'

module SteppingStone
  # A server's responsibility is to manage test case execution and mapping
  # from natural language actions to code.
  module Servers
    def self.boot!(name=:default, opts={})
      case name
      when :default, :text_mapper
        TextMapper.boot!(opts)
      else
        fail "No server for '#{name}' has been registered!"
      end
    end
  end
end
