module SteppingStone
  class TestCase
    attr_reader :sut, :actions, :result

    def initialize(sut, *actions)
      @sut = sut
      @actions = actions
      @result = :pending
    end

    def execute!
      with_start_and_end do
        results = []
        actions.each do |action|
          action_result = sut.apply(action)
          results << action_result
          break unless action_result == :passed
        end
        @result = results.last
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
        sut.start_test_case(self)
        block.call
        sut.end_test_case(self)
      end
    end
  end
end
