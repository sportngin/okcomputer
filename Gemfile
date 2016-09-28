source 'https://rubygems.org'
RAILS_VERSION = ENV.fetch('RAILS_VERSION', '5.0')

gem 'rails', "~> #{RAILS_VERSION}.0"
gem 'test-unit', '~> 3.0' if RUBY_VERSION >= '2.2' && RAILS_VERSION == '3.2'

group :test do
  # Load code coverage in Gemfile for explicit require: false
  gem 'coveralls', require: false
  gem 'simplecov', require: false
  gem 'pry'

  # BundleAuditCheck gems
  gem 'bundler-audit', require: false
  # Add a gem with a security advisory:
  # https://github.com/rubysec/ruby-advisory-db/blob/master/gems/paperclip/CVE-2015-2963.yml
  gem 'paperclip', '= 4.2.1'
end

gemspec
