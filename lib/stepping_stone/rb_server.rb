require 'stepping_stone/rb_server/context'

module SteppingStone
  class RbServer
    attr_reader :results, :context

    def initialize(results)
      @results = results
    end

    def execute(test_case)
      with_start_and_end(test_case) do
        test_case.each do |action|
          results[action] = apply(action)
        end
      end
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

    private

    def with_start_and_end(test_case, &block)
      unless test_case.empty?
        start_test(test_case)
        block.call
        end_test(test_case)
      end
    end
  end
end
