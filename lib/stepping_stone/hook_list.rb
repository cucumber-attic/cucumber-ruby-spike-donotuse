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

    def invoke(&run)
      compose_around(&compose_before_and_after(&run)).call
    end

    private

    def compose_around(&run)
      hooks[:around].inject(run) do |inside, outside|
        lambda { outside.call(inside) }
      end
    end

    def compose_before_and_after(&run)
      lambda do
        hooks[:before].each { |hook| hook.call }
        run.call
        hooks[:after].each { |hook| hook.call }
      end
    end
  end
end
