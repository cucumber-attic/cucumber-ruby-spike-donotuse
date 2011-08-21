module SteppingStone
  module TextMapper
    class UndefinedMappingError < NameError
      def initialize(missing)
        @missing = missing
      end

      def to_s
        "No mapping found that matches: #{@missing}"
      end
    end

    class MappingPool
      include Enumerable

      attr_reader :mappings

      def initialize(*mappings)
        @mappings = mappings
      end

      def find(pattern)
        mappings.find do |mapping|
          mapping.match(pattern)
        end
      end

      def find!(pattern)
        find(pattern) or raise(UndefinedMappingError.new(pattern))
      end

      def add(mapping)
        mappings << mapping
      end

      def empty?
        mappings.empty?
      end

      def each(&block)
        mappings.each(&block)
      end
    end
  end
end
