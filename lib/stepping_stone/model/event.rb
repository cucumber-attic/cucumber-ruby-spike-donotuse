module SteppingStone
  module Model
    class Event
      attr_reader :action, :status, :value

      def initialize(action, status, value=nil)
        @action, @status, @value = action, status, value
      end

      # TODO: Is this the correct way to define == equality for an Event?
      def ==(other)
        status == other
      end
    end
  end
end

