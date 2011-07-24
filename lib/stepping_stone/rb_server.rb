require 'stepping_stone/model/event'
require 'stepping_stone/text_mapper/namespace'
require 'stepping_stone/code_loader'

module SteppingStone
  # The server's responsibility is to execute a test case and communicate
  # the result of each action to its client via the supplied callback.
  class RbServer
    class Session
      attr_reader :context, :test_case

      def initialize(context, test_case)
        @context = context
        @test_case = test_case
      end

      def setup
        Model::Event.new(:before, :event, context.setup(test_case))
      end

      def teardown
        Model::Event.new(:after, :event, context.teardown(test_case))
      end

      def apply(action)
        Model::Event.new(action, :passed, context.dispatch(action))
      rescue RSpec::Expectations::ExpectationNotMetError => e
        Model::Event.new(action, :failed, e)
      rescue TextMapper::UndefinedMappingError => e
        Model::Event.new(action, :undefined, e)
      end

      def skip(action)
        Model::Event.new(action, :skipped)
      end
    end

    # Called by Cucumber when it's time to start executing features. Non-idempotent,
    # invasive and environment-related startup code should go here.
    def self.boot!
      server = self.new
      SteppingStone.const_set(:Mapper, server.dsl_module)
      CodeLoader.require_glob("mappers", "**/*")
      server
    end

    attr_accessor :mapper_namespace

    def initialize
      @mapper_namespace = TextMapper::Namespace.new
    end

    def start_test(test_case)
      yield Session.new(mapper_namespace.build_context, test_case)
    end

    def add_hook(hook)
      mapper_namespace.add_hook(hook)
    end

    def dsl_module
      @dsl_module ||= mapper_namespace.to_extension_module
    end
  end
end
