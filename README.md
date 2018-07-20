# FWMT Job Control

## Installation
Install the RubyGems the application depends on by running `bundle install`.

## Running
To run this application in development using its [Rackup](http://rack.github.io/) file use:

  `bundle exec rackup config.ru` (the `config.ru` may be omitted as Rack looks for this file by default)

and access using [http://localhost:9292](http://localhost:9292). To reload the application using the [Rerun](https://github.com/alexch/rerun) RubyGem every time a file changes use:

  `bundle exec rerun rackup`

## Copyright
Copyright (C) 2018 Crown Copyright (Office for National Statistics)