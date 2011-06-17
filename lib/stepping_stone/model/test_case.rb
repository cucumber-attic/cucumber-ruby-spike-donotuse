module SteppingStone
  module Model
    class TestCase
      include Enumerable

      attr_reader :actions

      # uri: TestCase identifier. URI fragments are allowed.
      # actions: list of actions to be applied to the SUT for this test case
      #
      # def initialize(uri, actions)
      #   @uri = uri
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
