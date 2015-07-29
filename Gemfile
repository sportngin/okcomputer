source "http://rubygems.org"

case ENV['RAILS_VERSION'];
when /3.2/
  gem "rails", "~> 3.2.0"
when /4.0/
  gem "rails", "~> 4.0.0"
when /4.1/
  gem "rails", "~> 4.1.0"
else
  gem "rails", "~> 4.2.0"
end

group :test do
  gem 'webmock'
end

gemspec
