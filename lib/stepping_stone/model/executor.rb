module SteppingStone
  module Model
    class Executor
      attr_reader :sut, :events

      def initialize(sut)
        @sut = sut
        @events = []
      end

      def execute(test_case)
        event(:before, sut.start_test(test_case))
        test_case.each do |action|
          sut.dispatch(action)
          event(:dispatch, action[0])
        end
        event(:after, sut.end_test(test_case))
      end

      private

      def event(name, value)
        @events << [name, value]
      end
    end
  end
end
