module SteppingStone
  module Servers
    module Rb
      class Result
        attr_reader :status, :value

        def initialize(status, value)
          @status = status
          @value = value
        end

        def ==(obj)
          value == obj
        end

        def passed?
          status == :passed
        end

        def undefined?
          status == :undefined
        end

        def failed?
          status == :failed
        end
      end

      class Context
        attr_accessor :mappings

        def mappers=(mappers)
          mappers.each { |mapper| extend(mapper) }
        end

        def dispatch(pattern)
          mapping = mappings.find_mapping(pattern)
          Result.new(:passed, mapping.call(self, pattern))
        rescue TextMapper::UndefinedMappingError => error
          Result.new(:undefined, error)
        rescue RSpec::Expectations::ExpectationNotMetError => error
          Result.new(:failed, error)
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
