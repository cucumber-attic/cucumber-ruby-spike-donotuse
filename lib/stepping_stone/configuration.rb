require 'stepping_stone/hooks'

module SteppingStone
  class Configuration
    include Hooks::FluentDsl

    def global_opts
      @global_opts ||= {}
    end
  end
end
