require 'stepping_stone/model/events'
require 'stepping_stone/text_mapper/namespace'
require 'stepping_stone/code_loader'

require 'stepping_stone/servers/rb/session'
require 'stepping_stone/servers/rb/context'

module SteppingStone
  module Servers
    class Rb
      # Called by Cucumber when it's time to start executing features. Non-idempotent,
      # invasive and environment-related startup code should go here.
      def self.boot!
        server = self.new
        SteppingStone.const_set(:Mapper, server.dsl_module)
        CodeLoader.require_glob("mappers", "**/*")
        server
      end

      attr_accessor :mapper_namespace

      def initialize(env_hooks = {})
        @env_hooks = env_hooks
        @mapper_namespace = TextMapper::Namespace.new
      end

      def start_test(test_case)
        @env_hooks[:before].call
        session = Servers::Rb::Session.new(build_context, test_case)
        yield session
        session.end_test
        @env_hooks[:after].call
      end

      def add_mapping(mapping)
        mapper_namespace.add_mapping(mapping)
      end

      def hooks
        mapper_namespace.hooks
      end

      def mappings
        mapper_namespace.mappings
      end

      def build_context
        mapper_namespace.build_context(Servers::Rb::Context.new)
      end

      def dsl_module
        @dsl_module ||= mapper_namespace.to_extension_module
      end
    end
  end
end
