require 'text_mapper/namespace'

require 'stepping_stone/model/doc_string'
require 'stepping_stone/model/data_table'
require 'stepping_stone/code_loader'

require 'stepping_stone/servers/text_mapper/hooks'
require 'stepping_stone/servers/text_mapper/context'

module SteppingStone
  module Servers
    class TextMapper
      # Called by Cucumber when it's time to start executing features. Non-idempotent,
      # invasive and environment-related startup code should go here.
      def self.boot!(opts)
        server = self.new
        SteppingStone.const_set(:Mapper, server.dsl_module)
        CodeLoader.require_glob("mappers", "**/*")
        server
      end

      attr_accessor :mapper_namespace

      def initialize
        @around_hook = AroundHook.new
        @mapper_namespace = ::TextMapper::Namespace.new({ SteppingStone::Model::DocString => :DocString,
                                                          SteppingStone::Model::DataTable => :DataTable })
        lambda do |namespace|
          @mapper_namespace.define_method(:around) { |*args, &hook| namespace.add_around_hook(*args, &hook) }
          @mapper_namespace.define_method(:before) { |*args, &hook| namespace.add_mapping(HookMapping.new(:setup, args, &hook)) }
          @mapper_namespace.define_method(:after) { |*args, &hook| namespace.add_mapping(HookMapping.new(:teardown, args, &hook)) }
        end.call(self)
      end

      def start_test(test_case)
        session = new_context
        @around_hook.invoke(test_case.tags, session) do
          yield session
        end
      end

      def add_mixin(mixin)
        mapper_namespace.add_mixin(mixin)
      end

      def add_mapping(mapping)
        mapper_namespace.add_mapping(mapping)
      end

      def add_around_hook(*tag_exprs, &hook)
        @around_hook.add(tag_exprs, &hook)
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
