module SteppingStone
  class HookList
    attr_reader :around, :before, :after

    def initialize
      @around = []
      @before = []
      @after  = []
    end

    def add_around(&hook)
      around.push(hook)
    end

    def add_before(*tags, &hook)
      before.push(hook)
    end

    def add_after(&hook)
      after.push(hook)
    end

    def invoke(&run)
      compose_around(&compose_before_and_after(&run)).call
    end

    private

    def compose_around(&run)
      around.inject(run) do |inside, outside|
        lambda { outside.call(inside) }
      end
    end

    def compose_before_and_after(&run)
      lambda do
        before.each { |hook| hook.call }
        run.call
        after.each { |hook| hook.call }
      end
    end
  end
end
