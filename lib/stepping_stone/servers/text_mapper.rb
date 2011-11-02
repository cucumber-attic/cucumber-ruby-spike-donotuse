require 'stepping_stone/servers/text_mapper/cucumber_namespace'
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
        @mapper_namespace = CucumberNamespace.new
      end

      def start_test(test_case)
        session = new_context
        mapper_namespace.wrap_execution_of(session, test_case.tags) do
          yield session
        end
      end

      def add_mixin(mixin)
        mapper_namespace.add_mixin(mixin)
      end

      def add_mapping(mapping)
        mapper_namespace.add_mapping(mapping)
      end

      def add_wrapper(*tag_exprs, &hook)
        mapper_namespace.add_wrapper(*tag_exprs, &hook)
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
