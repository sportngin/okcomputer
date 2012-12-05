# OK Computer

Inspired by the ease of installing and setting up [fitter-happier] as a Rails
application's health check, but frustrated by its lack of flexibility, OK
Computer was born. It provides a robust endpoint to perform server health
checks with a set of built-in plugins, as well as a simple interface to add
your own custom checks.

## Installation

Add this line to your application's Gemfile:

    gem 'okcomputer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install okcomputer

## Usage

To perform the default checks (application running and database connection), do nothing other than adding to your application's Gemfile.

### Registering Additional Checks

Register additional checks in an initializer, like do:

```ruby
# config/initializers/okcomputer.rb
OKComputer::Registry.register "resque", OKComputer::Checks::Resque
OKComputer::Registry.register "load", OKComputer::Checks::CPULoad
```

TODO: Figure out interface for configuring checks (e.g., Resque looking for more than 100 jobs in the "critical" queue)

### Registering Custom Checks

TODO: Figre out interface for custom checks

## Performing Checks

* Perform a simple up check: http://example.com/okcomputer
* Perform all installed checks: http://example.com/okcomputer/all
* Perform a specific installed check: http://example.com/okcomputer/database

Checks are available as plain text (by default) or JSON by appending .json, e.g.:
* http://example.com/okcomputer.json
* http://example.com/okcomputer/all.json

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[fitter-happier]:https://rubygems.org/gems/fitter-happier
