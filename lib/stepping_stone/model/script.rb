require 'stepping_stone/model/request'

module SteppingStone
  module Model
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
        test_case.each do |instruction|
          yield Request.required(:map, instruction)
        end
        yield Request.new(:teardown, [test_case.name])
      end
    end
  end
end
