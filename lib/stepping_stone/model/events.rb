require 'forwardable'
require 'date'

module SteppingStone
  module Model
    module Events
      class Event
        extend Forwardable

        attr_reader :type, :name, :result, :created_at

        def initialize(type, name, result)
          @type, @name, @result = type, [name].flatten, result
          @created_at = DateTime.now
        end

        def_delegators :@result, :passed?, :failed?, :undefined?, :skipped?, :status

        def to_a
          [type, name, status]
        end

        def skip_next?
          failed?
        end

        def to_s
          ""
        end

        def include_in_history?
          failed?
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

