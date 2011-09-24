require 'stepping_stone/model/responder'
require 'stepping_stone/model/result'

module SteppingStone
  module Servers
    class TextMapper
      class Session
        attr_reader :context, :test_case, :responder

        def initialize(context, test_case, responder = Model::Responder.new)
          @context = context
          @test_case = test_case
          @responder = responder
        end

        def setup
          responder.setup(test_case_name, context.dispatch([:setup, test_case_metadata]))
        end

        def teardown
          responder.teardown(test_case_name, context.dispatch([:teardown, test_case_metadata]))
        end

        def apply(action)
          responder.apply(action, context.dispatch(action))
        end

        def before_apply(action)
          responder.before_apply(test_case_name, context.dispatch([:before_apply, {}]))
        end

        def after_apply(action)
          responder.after_apply(test_case_name, context.dispatch([:after_apply, {}]))
        end

        def skip(action)
          # TODO: Remove this. It's only here because we are reporting via a delegator.
          # Doing pub/sub with an observer or broadcaster should be much cleaner.
          responder.skip(action, Model::Result.new(:skipped))
        end

        def end_test
          # no-op
        end

        private

        def test_case_name
          test_case.name
        end

        def test_case_metadata
          test_case.metadata
        end
      end
    end
  end
end
