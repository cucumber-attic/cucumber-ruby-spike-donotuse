# Cucumber

Cucumber is a testing library that helps you bridge the gap between
the business and development sides of your software development team.

## Setup

    $ git submodule init
    $ git submodule update

## What is customer-friendly information?

* business readable
* semi-structured text or markup
* understandable by mere mortals

## Getting Started

First install Cucumber:

    $ gem install cucumber

Then generate the directories to contain the files Cucumber will use:

    $ cuke generate

This will create the following:

    cukes/
        features/
        lib/
        cukes_helper.rb

If you've used Cucumber at all, you should understand what the features
directory is for. If you haven't, that's where you'll be putting your
Gherkin-formatted feature files. The lib directory will contain your
mappings.

Once you have written some features and the mappings from the actions
described in them onto code that drives your system, you can start
executing the features:

    $ cuke exec cukes/features/my_lovely_feature.feature

And that's it. Millions of dollars and priceless fame await!

## Mappings

The heart of the problem Cucumber addresses is the best way to bind
plain text to programming language code. To do this Cucumber uses
mappings defined by the programmer that include enough information to
create a poor man's dynamic dispatch between plain text and Ruby.

As an example, consider building a whiz-bang, object-oriented calculator
for Ruby. Maybe it allows you to share your most favorite calculations
with people you barely know or something. Whatever the case, it's a
pretty big deal and you'd like to have some way to show the interested
venture capitalists (they're exceptionally dull VCs) what it is capable
of, but it doesn't have a web front-end yet and writing documentation is
terrible and enterprisey, so you decide to write Gherkin features
documenting all the great things one could with it. This way you get the
docs all serious business people love, but they'll fail when your code
changes, keeping you honest.

Your first feature looks like this:

    Feature: Addition
      Guess what Facebook doesn't have?
      The commutative property. Booyah!

      Scenario: Commutativity
        Given a calculator
        When 4 and 2 are added together
        Then the answer 6

        Given the calculator is cleared
        When 2 and 4 are added together
        Then the answer is 6

I can hear the revving of a lambo already! But some work still remains.
You need to let Cucumber know how to convert those steps into
actions on your calculator library. Let's get to work.

A mapping consists of a pattern and invocation information. To create
one you use the `def_map` macro. The first thing you need is to create a
calculator, so open `cukes/lib/calculator_mapper.rb` in your favorite editor
and type the following:

    class CalculatorMapper
      extend Cucumber::TextMapper

      def_map "a calculator" => :create

      def create
        @calculator = Calculator.new
      end
    end

Ok, simple enough. You execute the feature and the first step passes.
Now you need a mapper for steps that look like "When N and M are added
together". This is different than before because you need to capture
the values of N and M, so you add a map with capture groups and the
supporting method:

    def_map /(\d+) and (\d+) are added together/ => :add

    def add(n, m)
      @calculator.add(n, m)
    end

Now you're getting impatient, so rather than execute the feature you move
on to the verification step:

    def_map /the answer is (\d+)/ => :assert_answer

    def assert_answer(r)
      @calculator.answer.should == r
    end

With a great beating of the heart you execute the feature again and...
it fails. 4 + 2 is not 42. Not even a Hitchhiker's joke can console you.

What happened? Well, as you are no doubt aware, Ruby's String class
defines the plus sign as concatenation. `4 + 2` may be `6`, but `"4" +
"2"` is `"42"`. A decidedly unfroody beginning for your new venture. But
all is not lost. The capture groups from the regex need only be
converted into something appropriate (say, integers) before they are
sent to the calculator. Simple enough, you say, so you rewrite the `add`
method like so:

    def add(n, m)
      @calculator.add(n.to_i, m.to_i)
    end

And `assert_answer`, too:

    def assert_answer(r)
      @calculator.answer.should == r.to_i
    end

Now you run the feature, and it passes. But something doesn't feel
right. You now have these calls to `#to_i` everywhere, and you loathe
having to sprinkle them throughout your testing API. Luckily, there is a
better way. Let's remove those conversion methods and rewrite our maps
like this:

    def_map /(\d+) and (\d+) are added together/ => [:add, Integer, Integer]
    def_map /the answer is (\d+)/ => [:assert_answer, Integer]

Now the captures will be converted into integers before they are sent to
the named method! All the tests pass and you don't have to worry about
transforming the data within the helper method. Hooray!

Newly invigorated, you implement the remaining pending map:

    def_map "the calculator is cleared" => :clear

    def clear
      @calculator.clear
    end

Now your entire mapper looks like this:

    class CalculatorMapper
      extend Cucumber::TextMapper

      def_map "a calculator"                       => :create
      def_map "the calculator is cleared"          => :clear
      def_map /(\d+) and (\d+) are added together/ => [:add, Integer, Integer]
      def_map /the answer is (\d+)/                => [:assert_answer, Integer]

      def create
        @calculator = Calculator.new
      end

      def clear
        @calculator.clear
      end

      def add(n, m)
        @calculator.add(n, m)
      end

      def assert_answer(r)
        @calculator.answer.should == r
      end
    end

Not bad, eh? But you still feel like something is off. There is a lot of
duplication between the macros, the helper methods and the instance
methods of the Calculator class. Why can't you just write something like
this?:

    class CalculatorMapper
      extend Cucumber::TextMapper

      def_subject "a calculator"                   => Calculator, :new
      def_map "the calculator is cleared"          => :clear
      def_map /(\d+) and (\d+) are added together/ => [:add, Integer, Integer]
      def_map /the answer is (\d+)/                => [:assert_answer, Integer]

      def assert_answer(r)
        calculator.answer.should == r
      end
    end

Good news: you can! But please keep in mind these are only the basics.

## Architecture

Frontend: compilers
Backend: servers

## Copyright

Copyright (c) 2011 Mike Sassak. See LICENSE for details.
