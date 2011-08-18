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
          mapping.call(self, pattern)
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
