module StepMapper
  def self.all_mappers
    @mappers ||= []
  end

  def self.extended(mapper)
    all_mappers << mapper
  end

  def mappings
    @mappings ||= {}
  end

  def has_map_for?(action)
    mappings.has_key?(action)
  end

  def def_map(mapping)
    from, to = mapping.shift
    mappings[from] = to
  end
end

module X
  extend StepMapper
  def_map :a => :b

  def b
    @foo = 10
  end
end

module Y
  extend StepMapper
  def_map :c => :d

  def d
    puts @foo
  end
end

class Context
  def mappers
    self.class.included_modules.select { |mod| StepMapper === mod }
  end

  def dispatch(action)
    if mapper = mappers.find { |m| m.has_map_for?(action) }
      meth = mapper.mappings[action]
      send(meth)
    else
      raise "Can't find mapping from '#{action}'"
    end
  end
end

StepMapper.all_mappers.each do |mapper|
  Context.send(:include, mapper)
end

context = Context.new
context.dispatch(:a)
context.dispatch(:c)
