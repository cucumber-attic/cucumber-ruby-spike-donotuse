require 'stepping_stone/model/responses'

module SteppingStone
  module Servers
    class TextMapper
      class Session
        attr_reader :context, :test_case

        def initialize(context, test_case)
          @context = context
          @test_case = test_case
        end

        def setup
          Model::Response.new(:setup, test_case_name, context.dispatch([:setup, test_case_metadata]))
        end

        def teardown
          Model::Response.new(:teardown, test_case_name, context.dispatch([:teardown, test_case_metadata]))
        end

        def apply(*action)
          Model::ActionResponse.new(:apply, action, context.dispatch(action))
        end

        def before_apply(*action)
          Model::Response.new(:before_apply, test_case_name, context.dispatch([:before_apply, {}]))
        end

        def after_apply(*action)
          Model::Response.new(:after_apply, test_case_name, context.dispatch([:after_apply, {}]))
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
