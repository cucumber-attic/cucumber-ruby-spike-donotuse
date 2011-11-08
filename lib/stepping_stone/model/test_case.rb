require 'stepping_stone/model/instruction'

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
        @instructions = build_instructions(instructions)
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

      private

      def build_instructions(instructions)
        [
          Instruction.new(:setup, [@name]),
          instructions.map { |i| Instruction.new(:dispatch, i) },
          Instruction.new(:teardown, [@name]),
        ].flatten
      end
    end
  end
end
