# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sevn/version"

Gem::Specification.new do |s|
  s.name        = 'sevn'
  s.version     = Sevn::VERSION
  s.date        = '2015-03-29'
  s.summary     = 'Sevn is an authorization gem inspired by Six'
  s.description = 'Mid-weigth authorization gem'
  s.authors     = ["Miguel Cervera"]
  s.email       = 'miguel@cervera.me'
  s.files       = []
  s.homepage    = 'https://github.com/mikeki/sevn'
  s.license     = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'awesome_print'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'codeclimate-test-reporter'
end
