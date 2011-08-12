require 'stepping_stone/model/events'
require 'stepping_stone/text_mapper/namespace'
require 'stepping_stone/code_loader'

module SteppingStone
  # The server's responsibility is to execute a test case and communicate
  # the result of each action to its client via the supplied callback.
  class RbServer
    class Session
      attr_reader :context, :test_case, :event_builder

      def initialize(context, test_case, event_builder = Model::Events)
        @context = context
        @test_case = test_case
        @event_builder = event_builder
      end

      def setup
        build_event(:setup, test_case_name, :passed, context.setup(test_case))
      rescue TextMapper::UndefinedMappingError
        build_event(:setup, test_case_name, :undefined)
      end

      def teardown
        build_event(:teardown, test_case_name, :passed, context.teardown(test_case))
      rescue TextMapper::UndefinedMappingError
        build_event(:teardown, test_case_name, :undefined)
      end

      def apply(action)
        build_event(:apply, action, :passed, context.dispatch(action))
      rescue RSpec::Expectations::ExpectationNotMetError => e
        build_event(:apply, action, :failed, e)
      rescue TextMapper::UndefinedMappingError => e
        build_event(:apply, action, :undefined, e)
      end

      def before_apply(action)
        build_event(:before_apply, test_case_name, :undefined)
      end

      def after_apply(action)
        build_event(:after_apply, test_case_name, :undefined)
      end

      def skip(action)
        build_event(:skip, action, :skipped)
      end

      def end_test
        # no-op
      end

      private

      def test_case_name
        test_case.name
      end

      def build_event(type, *args)
        event_builder.send(type, *args)
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
      session = Session.new(mapper_namespace.build_context, test_case)
      yield session
      session.end_test
    end

    def add_hook(hook)
      mapper_namespace.add_hook(hook)
    end

    def hooks
      mapper_namespace.hooks
    end

    def dsl_module
      @dsl_module ||= mapper_namespace.to_extension_module
    end
  end
end
