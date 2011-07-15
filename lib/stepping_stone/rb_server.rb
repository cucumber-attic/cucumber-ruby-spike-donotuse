require 'stepping_stone/text_mapper/namespace'
require 'stepping_stone/code_loader'

module SteppingStone
  # The server's responsibility is to execute a test case and communicate
  # the result of each action to its client via the supplied callback.
  class RbServer
    # Called by Cucumber when it's time to start executing features. Non-idempotent,
    # invasive and environment-related startup code should go here.
    def self.boot!
      server = self.new
      SteppingStone.const_set(:Mapper, server.mapper_namespace.to_extension_module)
      CodeLoader.require_glob("mappers", "**/*")
      server
    end
    attr_accessor :mapper_namespace, :context, :last_action

    def initialize
      @mapper_namespace = TextMapper::Namespace.new
    end

    # TODO: extract #apply into Model::Executor
    # Apply action to the SUT and return the result of the application
    def apply(action)
      return Model::Event.new(action, :skipped) if skip_action?
      @last_action = Model::Event.new(action, :passed, context.dispatch(action))
    rescue RSpec::Expectations::ExpectationNotMetError => e
      @last_action = Model::Event.new(action, :failed, e)
    rescue TextMapper::UndefinedMappingError
      @last_action = Model::Event.new(action, :undefined)
    end

    def dispatch(action)
      apply(action)
    end

    def start_test(test_case)
      @context = mapper_namespace.build_context
      Model::Event.new(:before, :event, @context.setup(test_case))
    end

    def end_test(test_case)
      Model::Event.new(:after, :event, @context.teardown(test_case))
    end

    private

    def skip_action?
      @last_action == :undefined or @last_action == :failed
    end
  end
end
