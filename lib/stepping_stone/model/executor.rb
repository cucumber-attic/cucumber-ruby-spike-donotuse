module SteppingStone
  module Model
    class Executor
      attr_reader :sut, :events

      def initialize(sut)
        @sut = sut
        @events = []
      end

      def execute(test_case, &block)
        if !test_case.empty?
          event(:before, sut.start_test(test_case))
          test_case.each do |action|
            sut.dispatch(action, &block)
            event(:dispatch, action[0])
          end
          event(:after, sut.end_test(test_case))
        end
      end

      private

      def event(name, value)
        @events << [name, value]
      end
    end
  end
end
