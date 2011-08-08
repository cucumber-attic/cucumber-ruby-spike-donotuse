module SteppingStone
  module Model
    class Event
      HOOKS   = [:setup, :teardown, :before_apply, :after_apply]
      ACTIONS = [:apply, :skip]

      class << self
        HOOKS.each do |factory|
          define_method(factory) do |*args|
            new(factory, *args)
          end
        end

        ACTIONS.each do |factory|
          define_method(factory) do |*args|
            new(factory, *args)
          end
        end
      end

      attr_reader :type, :name, :status, :value

      [:passed, :failed, :undefined].each do |status|
        define_method("#{status}?") do
          instance_variable_get(:@status) == status
        end
      end

      def initialize(type, name, status, value=nil)
        @type, @name, @status, @value = type, [name].flatten, status, value
      end

      def skip?
        failed? or undefined_action?
      end

      def undefined_action?
        undefined? and action?
      end

      def action?
        [:apply, :skip].include?(type)
      end

      def undefined_hook?
        undefined? and hook?
      end

      def hook?
        [:setup, :teardown, :before_apply, :after_apply].include?(type)
      end
    end
  end
end

