module SteppingStone
  module Servers
    class TextMapper
      class Hook
        def initialize(hook_type, *exprs, &body)
          @hook_type = hook_type
          @tag_expr = Gherkin::TagExpression.new(exprs)
          @body = body
        end

        def match(pattern, metadata={})
          if pattern.first == @hook_type
            tags = metadata.fetch(:tags, [])
            @tag_expr.eval(tags)
          end
        end

        def call(ctx, pattern)
          ctx.instance_exec(pattern, &@body)
        end

        def reify!
          self
        end
      end
    end
  end
end
