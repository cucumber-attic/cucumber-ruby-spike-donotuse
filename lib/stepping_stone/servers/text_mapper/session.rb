require 'stepping_stone/model/responses'

module SteppingStone
  module Servers
    class TextMapper
      class Session
        attr_reader :context

        def initialize(context)
          @context = context
        end

        def handle(request)
          if request.response_required?
            Model::ActionResponse.new(request.event, request.action, context.dispatch(request.action))
          else
            Model::Response.new(request.event, request.action, context.dispatch([request.event, request.arguments]))
          end
        end

        def end_test
          # no-op
        end
      end
    end
  end
end
