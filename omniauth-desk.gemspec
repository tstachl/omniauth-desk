# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "omniauth-desk/version"

Gem::Specification.new do |s|
  s.name        = "omniauth-desk"
  s.version     = OmniAuth::Desk::VERSION
  s.authors     = ["Thomas Stachl"]
  s.email       = ["tstachl@salesforce.com"]
  s.homepage    = "https://github.com/tstachl/omniauth-desk"
  s.summary     = %q{OmniAuth strategy for Desk.com}
  s.description = %q{OmniAuth strategy for Desk.com}

  s.rubyforge_project = "omniauth-desk"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_runtime_dependency 'omniauth', '~> 1.0'
  s.add_runtime_dependency 'omniauth-oauth', '~> 1.0'
  s.add_runtime_dependency 'multi_json', '~> 1.3.6'
  
  s.add_development_dependency 'rspec', '~> 2.7'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'webmock'
end