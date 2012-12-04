# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rspec/rails"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.use_transactional_fixtures = true

  # to prevent having to use use_route: :ok_computer on each controller spec
  config.before(:each, type: :controller) do
    @routes = OKComputer::Engine.routes
  end

  # to get routing specs to even work, since they have no use_route option
  config.before(:each, type: :routing) do
    @routes = OKComputer::Engine.routes
  end
end
