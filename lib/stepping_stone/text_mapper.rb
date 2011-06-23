require 'stepping_stone/text_mapper/mapping'
require 'stepping_stone/model/doc_string'

module SteppingStone
  module TextMapper
    module Dsl
      def self.extended(mapper)
        mapper.const_set(:DocString, Model::DocString)
      end

      def mappings
        @mappings ||= []
      end

      def def_map(mapping)
        mappings << Mapping.from_fluent(mapping)
      end
    end
  end
end
