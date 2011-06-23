require 'stepping_stone/text_mapper/namespace'
require 'stepping_stone/text_mapper/context'
require 'stepping_stone/code_loader'

module SteppingStone
  # The server's responsibility is to execute a test case and communicate
  # the result of each action to its client via the supplied callback.
  class RbServer
    class Result
      attr_reader :action, :result, :value
      def initialize(action, result, value=nil)
        @action, @result, value = action, result, value
      end

      # TODO: Is this the correct way to define == equality for a Result?
      def ==(other)
        result == other
      end
    end

    attr_accessor :context, :last_action

    def initialize
      @root = TextMapper::Namespace.build
      SteppingStone.const_set(:Mapper, @root)
      CodeLoader.require_glob("mappers", "**/*")
    end

    # Apply action to the SUT and return the result of the application
    def apply(action)
      return Result.new(action, :skipped) if skip_action?
      @last_action = Result.new(action, :passed, context.dispatch(action))
    rescue RSpec::Expectations::ExpectationNotMetError => e
      @last_action = Result.new(action, :failed, e)
    rescue TextMapper::Context::UndefinedMappingError
      @last_action = Result.new(action, :undefined)
    end

    def start_test(test_case)
      @context = TextMapper::Context.new(@root.mappers)
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

    private

    def skip_action?
      @last_action == :undefined or @last_action == :failed
    end
  end
end
