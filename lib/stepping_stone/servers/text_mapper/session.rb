require 'stepping_stone/model/responses'

module SteppingStone
  module Servers
    class TextMapper
      class Session
        attr_reader :context

        def initialize(context)
          @context = context
        end

        def perform(request)
          Model::Response.new(request, context.dispatch(request.signature))
        end

        def end_test
          # no-op
        end
      end
    end
  end
end
