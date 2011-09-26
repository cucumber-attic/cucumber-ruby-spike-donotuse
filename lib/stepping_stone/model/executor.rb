require 'observer'
require 'stepping_stone/model/responder'
require 'stepping_stone/model/result'

module SteppingStone
  module Model
    class Request
      attr_reader :event, :action

      def initialize(event, action=nil)
        @event = event
        @action = action
      end
    end

    # Script synthesizes the request stream for a given test case
    class Script
      include Enumerable

      attr_reader :test_case

      def initialize(test_case)
        @test_case = test_case
      end

      def each
        yield Request.new(:setup)
        test_case.each do |action|
          yield Request.new(:before_apply, action)
          yield Request.new(:apply, action)
          yield Request.new(:after_apply, action)
        end
        yield Request.new(:teardown)
      end
    end

    class Executor
      include Observable

      attr_reader :server
      attr_reader :responder

      def initialize(server)
        @server = server
        # Remove the responder stuff when the broadcaster / reporter protocol is fleshed out
        @responder = Model::Responder.new
      end

      def execute(test_case)
        script = Script.new(test_case)
        server.start_test(test_case) do |session|
          script.inject(:continue) do |state, request|
            case state
            when :continue
              response = handle(session, request)
              broadcast(response)
              response.halt? ? :skip : :continue
            when :skip
              broadcast_skip(request)
              :skip
            end
          end
        end
      end

      private

      def broadcast(response)
        changed
        notify_observers(response)
      end

      def broadcast_skip(request)
        if request.event == :apply
          response = responder.skip(request.action, Model::Result.new(:skipped))
          broadcast(response)
        end
      end

      def handle(session, request)
        session.send(request.event, *request.action)
      end
    end
  end
end
