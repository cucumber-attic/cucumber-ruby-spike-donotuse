require 'stepping_stone/servers/text_mapper/invocation'
require 'stepping_stone/model/result'
require 'stepping_stone/pending'

module SteppingStone
  module Servers
    class TextMapper
     class Context
        attr_accessor :namespace

        def mixins=(mixins)
          mixins.each { |mixin| extend(mixin) }
        end

        def pending(msg=nil)
          raise SteppingStone::Pending.new(msg)
        end

        # FIXME: Stop using exceptions for flow control for undefined mappings.
        # They are slow as molasses.
        def dispatch(instruction)
          pattern = instruction.to_a.flatten
          metadata = instruction.metadata
          matches = namespace.find_all_matching(pattern, metadata)
          invocation = Invocation.new(matches)
          results = invocation.call(self, pattern)
          Model::Result.new(instruction, :passed, results)
        rescue SteppingStone::Pending => error
          Model::Result.new(instruction, :pending, error)
        rescue ::TextMapper::UndefinedMappingError => error
          Model::Result.new(instruction, :undefined, error)
        rescue RSpec::Expectations::ExpectationNotMetError => error
          Model::Result.new(instruction, :failed, error)
        end

        def set_attribute(name, value)
          instance_variable_set(:"@#{name}", value)
        end

        def value_of(attribute)
          instance_variable_get(:"@#{attribute}")
        end

        def values_of(*attributes)
          attributes.map { |attr| value_of(attr) }
        end
      end
    end
  end
end
