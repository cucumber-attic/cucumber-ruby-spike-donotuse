require 'stepping_stone/text_mapper/mapping'

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
  end
end
