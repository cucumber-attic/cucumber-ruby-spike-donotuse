require 'stepping_stone/model/result'

module SteppingStone
  module Servers
    module Rb
     class Context
        attr_accessor :mappings

        def mappers=(mappers)
          mappers.each { |mapper| extend(mapper) }
        end

        def dispatch(pattern)
          mapping = mappings.find_mapping(pattern)
          Model::Result.new(:passed, mapping.call(self, pattern))
        rescue TextMapper::UndefinedMappingError => error
          Model::Result.new(:undefined, error)
        rescue RSpec::Expectations::ExpectationNotMetError => error
          Model::Result.new(:failed, error)
        end

        def setup(test_case)
          mapping = mappings.find_hook([:setup, :test_case])
          mapping.call(self, test_case)
        end

        def teardown(test_case)
          mapping = mappings.find_hook([:teardown, :test_case])
          mapping.call(self, test_case)
        end
      end
    end
  end
end
