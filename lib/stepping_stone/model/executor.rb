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

    class Script
      attr_reader :test_case

      def initialize(test_case)
        @test_case = test_case
      end

      def run(session, &executor)
        each do |request|
          case cmd = executor.call(request, handle(session, request))
          when :continue
            next
          when :stop
            break
          else
            raise "Script received bad command from the executor: '#{cmd}'"
          end
        end
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

      def handle(session, request)
        session.send(request.event, *request.action)
      end
    end

    class Executor
      include Observable

      attr_reader :server
      attr_reader :responder

      def initialize(server)
        @server = server
        @responder = Model::Responder.new
      end

      def execute(test_case)
        script = Script.new(test_case)
        server.start_test(test_case) do |session|
          script.run(session) do |request, response|
            if response.halt?
              broadcast(response)
              broadcast(responder.skip(request.action, Model::Result.new(:skipped)))
              :stop
            else
              broadcast(response)
              :continue
            end
          end
        end
      end

      def broadcast(msg)
        changed
        notify_observers(msg)
      end
    end
  end
end
