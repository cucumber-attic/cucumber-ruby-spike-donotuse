module SteppingStone
  module Model
    class Event
      attr_reader :name, :status, :value

      [:passed, :failed, :no_op].each do |status|
        define_method("#{status}?") do
          instance_variable_get(:@status) == status
        end
      end

      def initialize(name, status, value=nil)
        @name, @status, @value = name, status, value
      end

      # TODO: Is this the correct way to define == equality for an Event?
      def ==(other)
        status == other
      end
    end
  end
end

