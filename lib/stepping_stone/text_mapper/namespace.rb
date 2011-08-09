require 'stepping_stone/model/doc_string'
require 'stepping_stone/text_mapper/mapping'
require 'stepping_stone/text_mapper/mapping_pool'
require 'stepping_stone/text_mapper/context'
require 'stepping_stone/text_mapper/dsl'

module SteppingStone
  module TextMapper
    class Namespace
      attr_reader :mappings, :mappers, :hooks

      def initialize
        @mappings = MappingPool.new
        @hooks = MappingPool.new
        @mappers = []
      end

      def add_mapper(mapper)
        mappers << mapper
      end

      def add_mapping(mapping)
        mappings.add(mapping)
      end

      def find_mapping(from)
        mappings.find!(from)
      end

      def add_hook(hook)
        hooks.add(hook)
      end

      def find_hook(from)
        hooks.find!(from)
      end

      def build_context
        TextMapper::Context.new(self, mappers)
      end

      def to_extension_module
        Dsl.new(self, { Model::DocString => :DocString }).to_module
      end
    end
  end
end

