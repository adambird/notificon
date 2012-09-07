$:.push File.expand_path("../lib", __FILE__)
require "notificon/version"

Gem::Specification.new do |s|
  s.name        = "notificon"
  s.version     = Notificon::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Gem for tracking and managing application notifications"
  s.email       = "adam.bird@gmail.com"
  s.homepage    = "http://github.com/adambird/notificon"
  s.description = "Gem for tracking and managing application notifications"
  s.authors     = ['Adam Bird']

  s.files         = Dir["lib/**/*"]
  s.test_files    = Dir["spec/**/*"]
  s.require_paths = ["lib"]

  s.add_dependency('mongo', '~> 1.6')
  s.add_dependency('bson_ext', '~> 1.6')
  s.add_dependency('addressable', '~> 2.2')
end