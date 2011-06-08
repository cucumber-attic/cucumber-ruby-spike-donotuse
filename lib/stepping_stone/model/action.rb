module SteppingStone
  module Model
    class Action
      # TODO: Can we replace this with a bare Pattern?
      attr_reader :elements

      def initialize(*elements)
        @elements = elements.collect(&:freeze)
        @elements.freeze
      end

      def to_a
        elements
      end

      def to_s
        elements.join
      end
    end
  end
end
