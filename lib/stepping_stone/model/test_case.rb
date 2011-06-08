module SteppingStone
  module Model
    class TestCase
      include Enumerable

      attr_reader :actions

      def initialize(*actions)
        @actions = actions
      end

      def each(&blk)
        @actions.each(&blk)
      end

      def empty?
        @actions.empty?
      end
    end
  end
end
