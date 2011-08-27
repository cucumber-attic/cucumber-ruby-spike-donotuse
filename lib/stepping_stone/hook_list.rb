module SteppingStone
  class HookList
    attr_reader :hooks

    def initialize
      @hooks = { :around => [],
                 :before => [],
                 :after  => [] }
    end

    def around(&hook)
      hooks[:around].push(hook)
    end

    def before(&hook)
      hooks[:before].push(hook)
    end

    def after(&hook)
      hooks[:after].push(hook)
    end

    def invoke(type, &run)
      if type == :around
        hooks[:around].inject(run) do |inside, outside|
          lambda { outside.call(inside) }
        end.call
      else
        hooks[type].each { |hook| hook.call }
      end
    end
  end
end
