require 'stepping_stone/text_mapper/context'

module SteppingStone
  # The server's responsibility is to execute a test case and communicate
  # the result of each action to its client via the supplied callback.
  class RbServer
    class Result
      attr_reader :action, :result, :value
      def initialize(action, result, value=nil)
        @action, @result, value = action, result, value
      end

      def ==(other)
        result == other
      end
    end

    attr_accessor :context, :last_action

    # rename missing to undefined
    def apply(action)
      return Result.new(action, :pending) if @last_action == :missing
      @last_action = Result.new(action, :passed, context.dispatch(action))
    rescue RSpec::Expectations::ExpectationNotMetError => e
      @last_action = Result.new(action, :failed, e)
    rescue TextMapper::Context::UndefinedMappingError
      @last_action = Result.new(action, :missing)
    end

    def start_test(test_case)
      @context = TextMapper::Context.new
    end

    def end_test(test_case)
      # no-op for the moment
    end

    def execute(test_case, &blk)
      if !test_case.empty?
        start_test(test_case)
        test_case.each do |action|
          blk.call(apply(action))
        end
        end_test(test_case)
      end
    end
  end
end
