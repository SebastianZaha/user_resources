$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "user_resources/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "user_resources"
  s.version     = UserResources::VERSION
  s.authors     = ["Sebastian Zaha"]
  s.email       = ["sebastian.zaha@gmail.com"]
  s.homepage    = ""
  s.summary     = "A library for streamlining resource handling in rails apps."
  s.description = ""

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'rails', '>= 3.2.16'
  # For rails dummy application
  s.add_development_dependency 'sqlite3'
end
