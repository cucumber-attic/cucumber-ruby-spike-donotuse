require 'stepping_stone/model/events'

module SteppingStone
  module Model
    class Responder
      HOOKS   = [:setup, :teardown, :before_apply, :after_apply]
      ACTIONS = [:apply, :skip]

      HOOKS.each do |factory|
        define_method(factory) do |*args|
          Events::HookEvent.new(factory, *args)
        end
      end

      ACTIONS.each do |factory|
        define_method(factory) do |*args|
          Events::ActionEvent.new(factory, *args)
        end
      end
    end
  end
end
