module SteppingStone
  module Model
    module Events
      HOOKS   = [:setup, :teardown, :before_apply, :after_apply]
      ACTIONS = [:apply, :skip]

      class << self
        HOOKS.each do |factory|
          define_method(factory) do |*args|
            HookEvent.new(factory, *args)
          end
        end

        ACTIONS.each do |factory|
          define_method(factory) do |*args|
            ActionEvent.new(factory, *args)
          end
        end
      end

      class Event
        attr_reader :type, :name, :status, :value

        [:passed, :failed, :undefined, :skipped].each do |status|
          define_method("#{status}?") do
            instance_variable_get(:@status) == status
          end
        end

        def initialize(type, name, status, value=nil)
          @type, @name, @status, @value = type, [name].flatten, status, value
        end
      end

      class HookEvent < Event
        def skip?
          failed?
        end

        def to_s
          ""
        end
      end

      class ActionEvent < Event
        def skip?
          failed? or undefined?
        end

        def to_s
          {
            :passed    => ".",
            :failed    => "F",
            :undefined => "U",
            :skipped   => "S"
          }[status]
        end
      end
    end
  end
end

