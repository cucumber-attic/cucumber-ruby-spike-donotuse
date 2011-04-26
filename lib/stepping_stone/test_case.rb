module SteppingStone
  class TestCase
    attr_reader :sut, :actions, :result

    def initialize(sut, *actions)
      @sut = sut
      @actions = actions
      @result = :pending
    end

    def execute!
      if !actions.empty?
        sut.start_test_case(self)

        results = []
        actions.each do |action|
          result = sut.apply(action)
          results << result
          break unless result == :passed
        end

        sut.end_test_case(self)

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
  end
end
