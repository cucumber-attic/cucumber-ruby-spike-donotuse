require 'gherkin/tag_expression'

module SteppingStone
  class Hooks
    attr_reader :hooks

    def initialize
      @hooks = { :around => [],
                 :before => [],
                 :after  => [] }
    end

    def add(type, *exprs, &hook)
      hooks[type] << [Gherkin::TagExpression.new(exprs), hook]
    end

    def invoke(tags=[], &run)
      compose(*filter(tags), run).call
    end

    def filter(tags)
      hooks.keys.map do |key|
        hooks[key].map do |expr, hook|
          hook if expr.eval(tags)
        end.reject(&:nil?)
      end
    end

    private

    def compose(around, before, after, run)
      around.inject(
        before_and_after(before, after, run)
      ) do |inside, outside|
        lambda { outside.call(inside) }
      end
    end

    def before_and_after(before, after, run)
      lambda do
        before.each(&:call)
        run.call
        after.each(&:call)
      end
    end
  end
end
