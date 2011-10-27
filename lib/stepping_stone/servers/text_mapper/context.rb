require 'stepping_stone/model/result'
require 'stepping_stone/pending'

module SteppingStone
  module Servers
    class TextMapper
      class Context
        attr_accessor :mappings

        def mappers=(mappers)
          mappers.each { |mapper| extend(mapper) }
        end

        def pending(msg=nil)
          raise SteppingStone::Pending.new(msg)
        end

        # FIXME: Stop using exceptions for flow control for undefined mappings.
        # They are slow as molasses.
        def dispatch(instruction)
          pattern = instruction.to_a.flatten
          metadata = instruction.metadata
          mapping = mappings.find_mapping(pattern, metadata)
          Model::Result.new(:passed, mapping.call(self, pattern), instruction)
        rescue SteppingStone::Pending => error
          Model::Result.new(:pending, error, instruction)
        rescue ::TextMapper::UndefinedMappingError => error
          Model::Result.new(:undefined, error, instruction)
        rescue RSpec::Expectations::ExpectationNotMetError => error
          Model::Result.new(:failed, error, instruction)
        end
      end
    end
  end
end
