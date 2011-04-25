module SteppingStone
  class TestCase
    attr_reader :sut, :actions

    def initialize(sut, *actions)
      @sut = sut
      @actions = actions
    end

    def execute!
      results = actions.collect do |action|
        sut.apply(action)
      end

      @result = results.uniq[0]
    end

    def passed?
      @result == :passed
    end

    def failed?
      !passed?
    end

    def pending?
      actions.empty? or @result == :pending
    end
  end
end
