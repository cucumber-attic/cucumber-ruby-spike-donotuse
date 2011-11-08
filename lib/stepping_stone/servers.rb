require 'stepping_stone/servers/text_mapper'

module SteppingStone
  # A server's responsibility is act as an intermediary
  # between the test runner and the system under test.
  module Servers
    def self.boot!(name, opts={})
      case name
      when :text_mapper
        TextMapper.boot!(opts)
      else
        fail "No server for '#{name}' has been registered!"
      end
    end
  end
end
