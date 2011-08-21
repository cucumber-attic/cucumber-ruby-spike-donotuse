require 'stepping_stone/model/result'

module SteppingStone
  module Servers
    class Rb
      class Context
        attr_accessor :mappings

        def mappers=(mappers)
          mappers.each { |mapper| extend(mapper) }
        end

        # FIXME: Stop using exceptions for flow control for undefined mappings.
        # They are slow as molasses.
        def dispatch(pattern)
          mapping = mappings.find_mapping(pattern)
          Model::Result.new(:passed, mapping.call(self, pattern))
        rescue TextMapper::UndefinedMappingError => error
          Model::Result.new(:undefined, error)
        rescue RSpec::Expectations::ExpectationNotMetError => error
          Model::Result.new(:failed, error)
        end

        def skip(pattern)
          Model::Result.new(:skipped)
        end

        def before_apply(pattern)
          mapping = mappings.find_hook([:before_apply, pattern])
          Model::Result.new(:passed, mapping.call(self, pattern))
        rescue TextMapper::UndefinedMappingError => error
          Model::Result.new(:undefined, error)
        rescue RSpec::Expectations::ExpectationNotMetError => error
          Model::Result.new(:failed, error)
        end

        def after_apply(pattern)
          mapping = mappings.find_hook([:after_apply, pattern])
          Model::Result.new(:passed, mapping.call(self, pattern))
        rescue TextMapper::UndefinedMappingError => error
          Model::Result.new(:undefined, error)
        rescue RSpec::Expectations::ExpectationNotMetError => error
          Model::Result.new(:failed, error)
        end

        def setup(test_case)
          mapping = mappings.find_hook([:setup])
          Model::Result.new(:passed, mapping.call(self, test_case))
        rescue TextMapper::UndefinedMappingError => error
          Model::Result.new(:undefined, error)
        rescue RSpec::Expectations::ExpectationNotMetError => error
          Model::Result.new(:failed, error)
        end

        def teardown(test_case)
          mapping = mappings.find_hook([:teardown])
          Model::Result.new(:passed, mapping.call(self, test_case))
        rescue TextMapper::UndefinedMappingError => error
          Model::Result.new(:undefined, error)
        rescue RSpec::Expectations::ExpectationNotMetError => error
          Model::Result.new(:failed, error)
        end
      end
    end
  end
end
