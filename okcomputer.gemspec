$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "okcomputer/version"

AUTHORS = {
  "Patrick Byrne" => "patrick.byrne@tstmedia.com",
}

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "okcomputer"
  s.version     = OKComputer::VERSION
  s.authors     = AUTHORS.keys
  s.email       = AUTHORS.values
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of OK Computer."
  s.description = "TODO: Description of OK Computer."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.0"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
end
