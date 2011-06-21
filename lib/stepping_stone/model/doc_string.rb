module SteppingStone
  module Model
    # Represents an inline argument in a step. Example:
    #
    #   Given the message
    #     """
    #     I like
    #     Cucumber sandwich
    #     """
    #
    # The text between the pair of <tt>"""</tt> is stored inside a DocString,
    # which is yielded to the StepDefinition block as the last argument.
    #
    # The StepDefinition can then access the String via the #to_s method. In the
    # example above, that would return: <tt>"I like\nCucumber sandwich"</tt>
    #
    # Note how the indentation from the source is stripped away.
    #
    # DocString is a subclass of String in case we need to modify its behavior in the future.
    DocString = Class.new(String)
  end
end
