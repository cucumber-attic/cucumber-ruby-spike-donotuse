require 'gherkin/tag_expression'

module SteppingStone
  class HookList
    attr_reader :around, :before, :after

    def initialize
      @around = []
      @before = {}
      @after  = []
    end

    def add_around(&hook)
      around.push(hook)
    end

    def add_before(*tags, &hook)
      before[hook] = Gherkin::TagExpression.new(tags)
    end

    def add_after(&hook)
      after.push(hook)
    end

    def invoke(filter=[], &run)
      compose_around(&compose_before_and_after(filter, &run)).call
    end

    private

    def compose_around(&run)
      around.inject(run) do |inside, outside|
        lambda { outside.call(inside) }
      end
    end

    def compose_before_and_after(filter, &run)
      lambda do
        filter_before(filter).each { |hook| hook.call }
        run.call
        after.each { |hook| hook.call }
      end
    end

    def filter_before(filter)
      before.select { |_, tags| tags.eval(filter) }.keys
    end
  end
end
