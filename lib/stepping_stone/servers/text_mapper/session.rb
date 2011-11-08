require 'stepping_stone/model/result'

module SteppingStone
  module Servers
    class TextMapper
      class Session
        def initialize(context)
          @context = context
        end

        def execute(instruction)
          if defined?(@last_result) and @last_result.halt?
            Model::Result.new(instruction, :skipped)
          else
            @last_result = @context.dispatch(instruction)
          end
        end

        def set_attribute(name, value)
          @context.set_attribute(name, value)
        end

        def value_of(attribute)
          @context.value_of(attribute)
        end

        def values_of(*attributes)
          @context.values_of(*attributes)
        end
      end
    end
  end
end
