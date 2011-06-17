require 'stepping_stone/text_mapper/context'

module SteppingStone
  # The server's responsibility is to execute a test case and communicate
  # the result of each action to its client via the supplied callback.
  class RbServer
    attr_accessor :context

    def execute(test_case)
      with_start_and_end(test_case) do
        test_case.each do |action|
          yield action, apply(action)
        end
      end
    end

    def apply(action)
      if @last_result == :missing
        :pending
      else
        @last_result = this_result = context.dispatch(action)
        this_result
      end
    end

    def start_test(test_case)
      @context = TextMapper::Context.new
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
