module SteppingStone
  module Model
    class Result
      attr_reader :action, :result, :value
      def initialize(action, result, value=nil)
        @action, @result, value = action, result, value
      end

      # TODO: Is this the correct way to define == equality for a Result?
      def ==(other)
        result == other
      end
    end
  end
end

