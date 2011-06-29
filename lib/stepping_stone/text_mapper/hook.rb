module SteppingStone
  module TextMapper
    class Hook
      def initialize(signature)
        @signature = Pattern.new(signature)
      end
    end
  end
end
