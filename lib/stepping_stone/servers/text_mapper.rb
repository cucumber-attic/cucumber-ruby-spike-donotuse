require 'text_mapper/namespace'

require 'stepping_stone/model/doc_string'
require 'stepping_stone/model/data_table'
require 'stepping_stone/code_loader'
require 'stepping_stone/servers/text_mapper/context'


module SteppingStone
  module Servers
    class TextMapper
      # Called by Cucumber when it's time to start executing features. Non-idempotent,
      # invasive and environment-related startup code should go here.
      def self.boot!(opts)
        server = self.new(opts[:hooks])
        SteppingStone.const_set(:Mapper, server.dsl_module)
        CodeLoader.require_glob("mappers", "**/*")
        server
      end

      attr_accessor :mapper_namespace
      attr_reader :hooks

      def initialize(hooks)
        @hooks = hooks
        @mapper_namespace = ::TextMapper::Namespace.new({ SteppingStone::Model::DocString => :DocString,
                                                          SteppingStone::Model::DataTable => :DataTable })
        @mapper_namespace.define_method(:around) { |*args, &hook| hooks.add(:around, *args, &hook) }
        @mapper_namespace.define_method(:before) { |*args, &hook| hooks.add(:before, *args, &hook) }
        @mapper_namespace.define_method(:after) { |*args, &hook| hooks.add(:after, *args, &hook) }
      end

      def start_test(test_case)
        hooks.invoke(test_case.tags) do
          yield new_context
        end
      end

      def add_mixin(mixin)
        mapper_namespace.add_mixin(mixin)
      end

      def add_mapping(mapping)
        mapper_namespace.add_mapping(mapping)
      end

      def listeners
        mapper_namespace.listeners
      end

      def mappings
        mapper_namespace.mappings
      end

      def new_context
        mapper_namespace.initialize_context(Servers::TextMapper::Context.new)
      end

      def dsl_module
        @dsl_module ||= mapper_namespace.to_extension_module
      end
    end
  end
end
