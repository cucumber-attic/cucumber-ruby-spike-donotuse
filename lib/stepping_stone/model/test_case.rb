module SteppingStone
  module Model
    class TestCase
      include Enumerable

      attr_reader :name, :instructions
      attr_accessor :tags

      # uri: TestCase identifier. URI fragments are allowed.
      # instructions: list of instructions to be sent to the SUT
      #
      def initialize(name, *instructions)
        @name = name
        @instructions = instructions
        @tags = []
      end

      def each(&blk)
        instructions.each(&blk)
      end

      def empty?
        instructions.empty?
      end

      def metadata
        {}
      end
    end
  end
end
