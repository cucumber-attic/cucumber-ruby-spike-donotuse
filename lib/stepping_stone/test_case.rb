module SteppingStone
  class TestCase
    include Enumerable

    attr_reader :actions #, :result

    def initialize(*actions)
      @actions = actions
      #@result = :pending
    end

    # Remove commented
    #def execute!(server)
      #with_start_and_end(server) do
        #actions.each do |action|
          #@result = server.apply(action)
          #break unless passed?
        #end
      #end
    #end

    def each(&blk)
      @actions.each(&blk)
    end

    #def passed?
      #result == :passed
    #end

    #def failed?
      #result == :failed
    #end

    #def pending?
      #result == :pending
    #end

    def empty?
      @actions.empty?
    end

    # Remove commented
    #private

    #def with_start_and_end(server, &block)
      #if !actions.empty?
        #server.start_test(self)
        #block.call
        #server.end_test(self)
      #end
    #end
  end
end
