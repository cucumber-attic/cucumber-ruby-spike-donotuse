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
  end
end
