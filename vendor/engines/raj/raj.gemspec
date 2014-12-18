$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "raj/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "raj"
  s.version     = Raj::VERSION
  s.authors     = ["shock"]
  s.email       = ["github@wdoughty.net"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Raj."
  s.description = "TODO: Description of Raj."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 3.2"
  s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
