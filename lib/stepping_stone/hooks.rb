require 'gherkin/tag_expression'

module SteppingStone
  class Hooks
    module FluentDsl
      def hooks
        @hooks ||= Hooks.new
      end

      def around(*args, &hook)
        hooks.add(:around, *args, &hook)
      end

      def before(*args, &hook)
        hooks.add(:before, *args, &hook)
      end

      def after(*args, &hook)
        hooks.add(:after, *args, &hook)
      end
    end

    attr_reader :hooks

    def initialize
      @hooks = { :around => [],
                 :before => [],
                 :after  => [] }
    end

    def add(type, *exprs, &hook)
      hooks[type] << [Gherkin::TagExpression.new(exprs), hook]
    end

    def invoke(tags=[], *args, &run)
      compose(*filter(tags), run, args).call
    end

    def filter(tags)
      hooks.keys.map do |key|
        hooks[key].map do |expr, hook|
          hook if expr.eval(tags)
        end.reject(&:nil?)
      end
    end

    private

    def compose(around, before, after, run, args)
      around.inject(
        before_and_after(before, after, run, args)
      ) do |inside, outside|
        lambda { outside.call(inside, *args) }
      end
    end

    def before_and_after(before, after, run, args)
      lambda do
        before.each { |hook| hook.call(*args) }
        run.call
        after.each { |hook| hook.call(*args) }
      end
    end
  end
end
