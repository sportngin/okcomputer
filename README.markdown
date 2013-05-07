[![Code Climate](https://codeclimate.com/github/sportngin/okcomputer.png)](https://codeclimate.com/github/sportngin/okcomputer)
[![Build Status](https://travis-ci.org/sportngin/okcomputer.png)](https://travis-ci.org/sportngin/okcomputer)
[![Coverage Status](https://coveralls.io/repos/sportngin/okcomputer/badge.png?branch=master)](https://coveralls.io/r/sportngin/okcomputer)

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

To perform the default checks (application running and ActiveRecord database
connection), do nothing other than adding to your application's Gemfile.

### If Not Using ActiveRecord

We also include a MongoidCheck, but do not register it. If you use Mongoid,
replace the default ActiveRecord check like so:

```ruby
OKComputer::Registry.register "database", OKComputer::MongoidCheck.new
```

If you use another database adapter, see Registering Custom Checks below to
build your own database check and register it with the name "database" to
replace the built-in check, or use `OKComputer::Registry.deregister "database"`
to stop checking your database altogether.

### Requiring Authentication

Optionally require HTTP Basic authentication to view the results of checks in an initializer, like so:

```ruby
# config/initializers/okcomputer.rb
OKComputer.require_authentication("username", "password")
```

### Registering Additional Checks

Register additional checks in an initializer, like so:

```ruby
# config/initializers/okcomputer.rb
OKComputer::Registry.register "resque_down", OKComputer::ResqueDownCheck.new
OKComputer::Registry.register "resque_backed_up", OKComputer::ResqueBackedUpCheck.new("critical", 100)
```

### Registering Custom Checks

The simplest way to register a check unique to your application is to subclass
OKComputer::Check and implement your own `#check` method, which sets the
display message with `mark_message`, and calls `mark_failure` if anything is
wrong.

```ruby
# config/initializers/okcomputer.rb
class MyCustomCheck < OKComputer::Check
  def check
    if rand(10).even?
      mark_message "Even is great!"
    else
      mark_failure
      mark_message "We don't like odd numbers"
    end
  end
end

OKComputer::Registry.register "check_for_odds", MyCustomCheck.new
```

## Performing Checks

* Perform a simple up check: http://example.com/okcomputer
* Perform all installed checks: http://example.com/okcomputer/all
* Perform a specific installed check: http://example.com/okcomputer/database

Checks are available as plain text (by default) or JSON by appending .json, e.g.:
* http://example.com/okcomputer.json
* http://example.com/okcomputer/all.json

## Deprecations and Breaking Changes

#### Deprecation of Check#call

Versions before 0.2.0 implemented a "#call" method which returned the message.
This has been deprecated and will be removed in a future version. Please
define a #check method which calls `mark_failure` and `mark_message` as
appropriate. In the meantime, OKComputer displays a warning and uses the result
of the #call method as the message.

#### Breaking Change of JSON Output

Versions before 0.3.0, when performing multiple checks, returned an Array of
the check results, each being a JSON object. Starting with 0.3.0, these are
combined into a single JSON object with each check having its own key. For
example:

**before 0.3.0**
```json
[{"check": "result"}, {"other": "result"}]
```

**0.3.0 and above**
```json
{"check": "result", "other": "result"}
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[fitter-happier]:https://rubygems.org/gems/fitter-happier

