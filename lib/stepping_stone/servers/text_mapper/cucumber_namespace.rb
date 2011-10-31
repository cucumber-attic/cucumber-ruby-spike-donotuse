require 'text_mapper/namespace'

require 'stepping_stone/model/doc_string'
require 'stepping_stone/model/data_table'

require 'stepping_stone/servers/text_mapper/hooks'

module SteppingStone
  module Servers
    class TextMapper
      class CucumberNamespace < ::TextMapper::Namespace
        CONST_ALIASES = {
          SteppingStone::Model::DocString => :DocString,
          SteppingStone::Model::DataTable => :DataTable
        }

        def initialize
          super(CONST_ALIASES)

          @execution_wrapper = AroundHook.new

          lambda do |ns|
            define_dsl_method(:around) do |*args, &hook|
              ns.add_wrapper(*args, &hook)
            end

            define_dsl_method(:before) do |*args, &hook|
              ns.add_mapping(HookMapping.new(:setup, args, &hook))
            end

            define_dsl_method(:after) do |*args, &hook|
              ns.add_mapping(HookMapping.new(:teardown, args, &hook))
            end
          end.call(self)
        end

        def add_wrapper(*tag_exprs, &hook)
          @execution_wrapper.add(tag_exprs, &hook)
        end

        def wrap_execution_of(ctx, tags=[], &continuation)
          @execution_wrapper.invoke(tags, ctx, &continuation)
        end
      end
    end
  end
end
