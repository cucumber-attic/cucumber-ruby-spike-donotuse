require 'stepping_stone/text_mapper/mapping'
require 'stepping_stone/model/doc_string'

module SteppingStone
  module TextMapper
    def self.mappers
      @mappers ||= []
    end

    def self.all_mappings
      mappers.inject([]) do |acc, mapper|
        acc << mapper.mappings
      end.flatten
    end

    def self.extended(mapper)
      mapper.extend(Dsl)
      mapper.const_set(:DocString, Model::DocString)
      mappers << mapper
    end

    module Dsl
      def mappings
        @mappings ||= []
      end

      def def_map(mapping)
        mappings << Mapping.from_fluent(mapping)
      end
    end
  end
end
