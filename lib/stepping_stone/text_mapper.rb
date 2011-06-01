module SteppingStone
  module TextMapper
    def self.mappers
      @mappers ||= []
    end

    def self.extended(mapper)
      mappers << mapper
    end

    def mappings
      @mappings ||= {}
    end

    def def_map(mapping)
      from, to = mapping.shift
      mappings[from] = to
    end
  end
end
