require 'stepping_stone/configuration'
require 'stepping_stone/model'
require 'stepping_stone/servers'
require 'stepping_stone/runner'
require 'stepping_stone/reporter'
require 'stepping_stone/observers'

module SteppingStone
  VERSION = "0.0.1"

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration if block_given?
  end
end
