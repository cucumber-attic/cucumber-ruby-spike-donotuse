require 'stepping_stone/model/responses'

module SteppingStone
  module Model
    class Responder
      HOOKS   = [:setup, :teardown, :before_apply, :after_apply]
      ACTIONS = [:apply, :skip]

      HOOKS.each do |factory|
        define_method(factory) do |*args|
          Response.new(factory, *args)
        end
      end

      ACTIONS.each do |factory|
        define_method(factory) do |*args|
          ActionResponse.new(factory, *args)
        end
      end
    end
  end
end
