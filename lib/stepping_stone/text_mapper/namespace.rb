require 'stepping_stone/model/doc_string'
require 'stepping_stone/text_mapper/mapping'

module SteppingStone
  module TextMapper
    module Namespace
      def self.build
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

      module Dsl
        def self.extended(mapper)
          mapper.const_set(:DocString, Model::DocString)
        end

        def mappings
          @mappings ||= []
        end

        def def_map(mapping)
          mappings << Mapping.from_fluent(mapping)
        end
      end
    end
  end
end

