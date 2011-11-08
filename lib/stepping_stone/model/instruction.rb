module SteppingStone
  module Model
    class Instruction
      attr_reader :name, :arguments, :metadata

      def initialize(name, arguments, metadata={})
        @name, @arguments, @metadata = name, arguments, metadata
      end

      def event
        @name
      end

      def response_required?
        @name == :dispatch
      end

      def to_a
        [@name, @arguments]
      end
    end
  end
end
