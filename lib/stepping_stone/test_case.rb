module SteppingStone
  class TestCase
    attr_reader :sut, :actions

    def initialize(sut, *actions)
      @sut = sut
      @actions = actions
    end

    def execute!
      results = []

      actions.each do |action|
        result = sut.apply(action)
        results << result
        break unless result == :passed
      end

      @result = results.uniq[0]
    end

    def passed?
      @result == :passed
    end

    def failed?
      !actions.empty? and !passed?
    end

    def pending?
      actions.empty? or @result == :pending
    end
  end
end
