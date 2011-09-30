module SteppingStone
  module Model
    class Request
      def self.required(event, arguments)
        self.new(event, arguments, true)
      end

      attr_reader :event, :arguments

      def initialize(event, arguments, response_required=false)
        @event, @arguments, @response_required = event, arguments, response_required
      end

      def signature
        [event, *arguments]
      end

      def response_required?
        @response_required
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
        # TODO: Track the result of yield to determine if we should continue
        yield Request.new(:setup, [test_case.name])
        test_case.each do |action|
          yield Request.required(:map, action)
        end
        yield Request.new(:teardown, [test_case.name])
      end
    end
  end
end
