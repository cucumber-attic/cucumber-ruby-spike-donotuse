module SteppingStone
  module Model
    class Event
      attr_reader :type, :name, :status, :value

      [:passed, :failed, :no_op].each do |status|
        define_method("#{status}?") do
          instance_variable_get(:@status) == status
        end
      end

      def initialize(type, name, status, value=nil)
        @type, @name, @status, @value = type, [name].flatten, status, value
      end

      # TODO: Is this the correct way to define == equality for an Event?
      def ==(other)
        status == other
      end
    end
  end
end

