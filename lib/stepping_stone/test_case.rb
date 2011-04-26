module SteppingStone
  class TestCase
    attr_reader :sut, :actions, :result

    def initialize(sut, *actions)
      @sut = sut
      @actions = actions
      @result = :pending
    end

    def execute!
      within_start_and_end do
        if !actions.empty?
          sut.start_test_case(self)

          results = []
          actions.each do |action|
            action_result = sut.apply(action)
            results << action_result
            break unless action_result == :passed
          end

          sut.end_test_case(self)

          @result = results.last
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

    def within_start_and_end(&block)
      block.call
    end
  end
end
