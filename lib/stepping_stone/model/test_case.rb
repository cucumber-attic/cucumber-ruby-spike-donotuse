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
      
      def to_a
        [@name, @arguments]
      end
    end
    
    class TestCase
      include Enumerable

      attr_reader :name, :instructions
      attr_accessor :tags

      # uri: TestCase identifier. URI fragments are allowed.
      # instructions: list of instructions to be sent to the SUT
      #
      def initialize(name, *instructions)
        @name = name
        @instructions = instructions.map { |i| Instruction.new(:map, i) }
        @instructions.unshift(Instruction.new(:setup, [@name]))
        @instructions.push(Instruction.new(:teardown, [@name]))
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
