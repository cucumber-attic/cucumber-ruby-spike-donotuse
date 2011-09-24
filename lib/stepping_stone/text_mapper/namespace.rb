require 'stepping_stone/model/doc_string'
require 'stepping_stone/model/data_table'
require 'stepping_stone/text_mapper/listener'
require 'stepping_stone/text_mapper/mapping_pool'
require 'stepping_stone/text_mapper/dsl'

module SteppingStone
  module TextMapper
    class Namespace
      attr_reader :mappings, :mappers

      def initialize
        @mappings = MappingPool.new
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

      def listeners
        mappings.select { |mapping| Listener === mapping }
      end

      def build_context(context)
        context.mappings = self
        context.mappers = mappers
        context
      end

      def to_extension_module
        Dsl.new(self, { Model::DocString => :DocString,
                        Model::DataTable => :DataTable }).to_module
      end
    end
  end
end

