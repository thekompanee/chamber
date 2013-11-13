# Build Status: [![Build Status](https://travis-ci.org/stevenhallen/chamber.png)]

# Chamber

Chamber lets you source your Settings from an arbitrary number of YAML files and
provides a simple mechanism for overriding settings from the ENV, which is
friendly to how Heroku addons work.

## Installation

Add this line to your application's Gemfile:

    gem 'chamber'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install chamber

## Usage

TODO: Write usage instructions here

## Ideas

* Add a rake task for validating environments (do all environments have the same
  settings?)

* Add a rake task for setting Heroku environment variables.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
