require 'stepping_stone/model/result'

module SteppingStone
  module Servers
    class Rb
      class Session
        attr_reader :context, :test_case, :event_builder

        def initialize(context, test_case, event_builder = Model::Events)
          @context = context
          @test_case = test_case
          @event_builder = event_builder
        end

        def setup
          build_event(:setup, test_case_name, context.dispatch([:setup, test_case_metadata]))
        end

        def teardown
          build_event(:teardown, test_case_name, context.dispatch([:teardown, test_case_metadata]))
        end

        def apply(action)
          build_event(:apply, action, context.dispatch(action))
        end

        def before_apply(action)
          build_event(:before_apply, test_case_name, context.dispatch([:before_apply, action]))
        end

        def after_apply(action)
          build_event(:after_apply, test_case_name, context.dispatch([:after_apply, action]))
        end

        def skip(action)
          build_event(:skip, action, context.skip(action))
        end

        def skip(action)
          build_event(:skip, action, Model::Result.new(:skipped))
        end

        def end_test
          # no-op
        end

        private

        def test_case_name
          test_case.name
        end

        def test_case_metadata
          {}
        end

        def build_event(type, *args)
          event_builder.send(type, *args)
        end
      end
    end
  end
end
