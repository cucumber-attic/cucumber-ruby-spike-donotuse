# Cucumber

Cucumber is a testing library that helps you bridge the gap between
the business and development sides of your software development team.

## Setup

    $ git submodule init
    $ git submodule update

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

## Architecture

Frontend: compilers
Backend: servers

## Copyright

Copyright (c) 2011 Mike Sassak. See LICENSE for details.
