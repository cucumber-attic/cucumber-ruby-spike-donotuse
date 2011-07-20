module SteppingStone
  module Model
    class Event
      attr_reader :action, :status, :value

      [:passed, :failed].each do |status|
        define_method("#{status}?") do
          instance_variable_get(:@status) == status
        end
      end

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

