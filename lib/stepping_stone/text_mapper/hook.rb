module SteppingStone
  module TextMapper
    class Hook
      def initialize(signature, &blk)
        @signature = Pattern.new(signature)
        @blk = blk
      end

      def match(pattern)
        @signature === pattern
      end

      def call(context, test_case)
        @blk.call(test_case)
      end
    end
  end
end
