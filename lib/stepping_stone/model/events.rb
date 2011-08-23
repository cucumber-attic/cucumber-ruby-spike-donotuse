require 'forwardable'

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
        extend Forwardable

        attr_reader :type, :name, :result

        def initialize(type, name, result)
          @type, @name, @result = type, [name].flatten, result
        end

        def_delegators :@result, :passed?, :failed?, :undefined?, :skipped?, :status

        def to_a
          [type, name, status]
        end
      end

      class HookEvent < Event
        def skip_next?
          failed?
        end

        def to_s
          ""
        end
      end

      class ActionEvent < Event
        def skip_next?
          failed? or undefined? or skipped?
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

