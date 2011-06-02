require 'stepping_stone/pattern'

module SteppingStone
  module TextMapper
    def self.mappers
      @mappers ||= []
    end

    def self.extended(mapper)
      mapper.extend(Dsl)
      mappers << mapper
    end

    module Dsl
      def mappings
        @mappings ||= []
      end

      def def_map(mapping)
        mappings << Mapping.build(mapping)
      end
    end

    class Mapping
      def self.build(dsl_args)
        from, to = dsl_args.shift
        new(from, to)
      end

      attr_accessor :from, :to

      def initialize(from, to)
        @from = from
        @to = to # MethodSignature.new(to) ???
        @pattern = Pattern.new(from)
      end

      def match(pattern)
        @pattern === pattern
      end

      def captures_from(str)
        Regexp.new(from).match(str).captures
      end
    end
  end
end
