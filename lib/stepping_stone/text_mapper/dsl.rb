module SteppingStone
  module TextMapper
    class Dsl
      def initialize(mappings, const_aliases={})
        @mappings = mappings
        @const_aliases = const_aliases
      end

      def to_module
        lambda do |mappings, const_aliases|
          Module.new do
            metaclass = (class << self; self; end)

            metaclass.send(:define_method, :extended) do |mapper|
              const_aliases.each_pair do |const, const_alias|
                mapper.const_set(const_alias, const)
              end
              mappings.add_mapper(mapper)
            end

            define_method(:def_map) do |dsl_args|
              mappings.add_mapping(Mapping.from_fluent(dsl_args))
            end
          end
        end.call(@mappings, @const_aliases)
      end
    end
  end
end
