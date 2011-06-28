require 'stepping_stone/model/doc_string'
require 'stepping_stone/text_mapper/mapping'

module SteppingStone
  module TextMapper
    class Namespace
      class UndefinedMappingError < NameError
        def initialize(missing)
          @missing = missing
        end

        def to_s
          "No mapping found that matches: #{@missing}"
        end
      end

      class MappingPool
        attr_reader :mappings

        def initialize
          @mappings = []
        end

        def add_mapping(mapping)
          mappings << mapping
        end

        def find_mapping(from)
          mappings.find { |mapping| mapping.match(from) } or raise(UndefinedMappingError.new(from))
        end
      end

      attr_reader :mappings, :mappers

      def initialize
        @mappings = []
        @mappers = []
      end

      def add_mapper(mapper)
        mappers << mapper
      end

      def add_mapping(mapping)
        mappings << mapping
      end

      def find_mapping(from)
        mappings.find { |mapping| mapping.match(from) } or raise(UndefinedMappingError.new(from))
      end

      def build_context
        TextMapper::Context.new(self, mappers)
      end

      def to_extension_module
        lambda do |mappings|
          Module.new do
            metaclass = (class << self; self; end)

            metaclass.send(:define_method, :extended) do |mapper|
              mapper.const_set(:DocString, Model::DocString)
              mappings.add_mapper(mapper)
            end

            define_method(:def_map) do |dsl_args|
              mappings.add_mapping(Mapping.from_fluent(dsl_args))
            end
          end
        end.call(self)
      end
    end
  end
end

