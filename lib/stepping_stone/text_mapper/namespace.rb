module SteppingStone
  module TextMapper
    module Namespace
      def self.root
        Module.new do
          def self.mappers
            @mappers ||= []
          end

          def self.all_mappings
            mappers.inject([]) do |acc, mapper|
              acc << mapper.mappings
            end.flatten
          end

          def self.extended(mapper)
            mapper.extend(Dsl)
            mappers << mapper
          end
        end
      end
    end
  end
end

