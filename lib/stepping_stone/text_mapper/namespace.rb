require 'stepping_stone/model/doc_string'
require 'stepping_stone/text_mapper/mapping'
require 'stepping_stone/text_mapper/mapping_pool'
require 'stepping_stone/text_mapper/context'

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
        lambda do |mappings, const_aliases|
          Module.new do
            metaclass = (class << self; self; end)

            metaclass.send(:define_method, :extended) do |mapper|
              const_aliases.each_pair do |const, const_alias|
                mapper.const_set(const_alias, const)
              end
              mappings.add_mapper(mapper)
            end

            define_method(:def_map) do |dsl_args|
              mappings.add_mapping(Mapping.from_fluent(dsl_args))
            end
          end
        end.call(self, { Model::DocString => :DocString }) # TODO: Extract this concern for real
      end
    end
  end
end

