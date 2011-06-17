module SteppingStone
  class Results
    def initialize
      @results = []
    end

    def add_result(action, result)
      @results << [action, result]
    end

    def to_s
      @results.map do |_, result|
        case result
        when :pending
          "P"
        when :passed
          "."
        when :failed
          "F"
        when :missing
          "M"
        else
          raise "This should never happen"
        end
      end.join
    end
  end
end
