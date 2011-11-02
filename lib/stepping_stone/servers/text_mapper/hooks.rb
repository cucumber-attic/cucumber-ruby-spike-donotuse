require 'gherkin/tag_expression'

module SteppingStone
  module Servers
    class TextMapper
      class HookMapping
        def initialize(event, exprs=[], &body)
          @event = event
          @tag_expr = Gherkin::TagExpression.new(exprs)
          @body = body
        end

        def match(pattern, metadata={})
          if pattern.first == @event
            tags = metadata.fetch(:tags, [])
            @tag_expr.eval(tags)
          end
        end

        def call(ctx, pattern=[])
          ctx.instance_exec(pattern, &@body)
        end

        def reify!
          self
        end

        def id
          object_id
        end
      end

      class AroundHook
        attr_reader :wrappers

        def initialize
          @wrappers = []
        end

        def add(exprs=[], &wrapper)
          wrappers.push([Gherkin::TagExpression.new(exprs), wrapper])
        end

        def invoke(tags=[], *args, &continuation)
          compose(filter(tags), args, continuation).call
        end

       private

        def compose(wrappers, args, continuation)
          wrappers.inject(continuation) do |inner, outer|
            lambda { outer.call(inner, *args) }
          end
        end

        def filter(wanted)
          wrappers.inject([]) do |matching, (expr, hook)|
            expr.eval(wanted) ? matching.push(hook) : matching
          end
        end
      end
    end
  end
end
