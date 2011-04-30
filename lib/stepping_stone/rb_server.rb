require 'stepping_stone/rb_server/context'

module SteppingStone
  class RbServer
    attr_reader :context

    def initialize(context = Context.new)
      @context = context
    end

    def apply(action)
      context.dispatch(action)
    end

    def start_test(test_case)
      @context = Context.new
    end

    def end_test(test_case)
      # no-op for the moment
    end
  end
end
