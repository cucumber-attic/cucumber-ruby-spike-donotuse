module SteppingStone
  class TestCase
    attr_reader :server, :actions, :result

    def initialize(server, *actions)
      @server = server
      @actions = actions
      @result = :pending
    end

    def execute!
      with_start_and_end do
        actions.each do |action|
          @result = server.apply(action)
          break unless passed?
        end
      end
    end

    def passed?
      result == :passed
    end

    def failed?
      result == :failed
    end

    def pending?
      result == :pending
    end

    private

    def with_start_and_end(&block)
      if !actions.empty?
        server.start_test(self)
        block.call
        server.end_test(self)
      end
    end
  end
end
