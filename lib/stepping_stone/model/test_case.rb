module SteppingStone
  module Model
    class TestCase
      include Enumerable

      attr_reader :name, :actions

      # uri: TestCase identifier. URI fragments are allowed.
      # actions: list of actions to be applied to the SUT for this test case
      #
      # def initialize(uri, actions)
      #   @uri = uri
      def initialize(name, *actions)
        @name = name
        @actions = actions
      end

      def each(&blk)
        @actions.each(&blk)
      end

      def empty?
        @actions.empty?
      end

      def metadata
        {}
      end
    end
  end
end
