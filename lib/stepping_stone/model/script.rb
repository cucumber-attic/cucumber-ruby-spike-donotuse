module SteppingStone
  module Model
    class Request
      attr_reader :event, :action, :arguments

      def initialize(event, action, arguments=nil)
        @event = event
        @action = action
        @arguments = arguments
      end

      def response_required?
        event == :apply
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
        yield Request.new(:setup, test_case.name, test_case.metadata)
        test_case.each do |action|
          yield Request.new(:apply, action)
        end
        yield Request.new(:teardown, test_case.name, test_case.metadata)
      end
    end
  end
end
