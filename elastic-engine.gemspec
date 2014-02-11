# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'elastic_engine/version'

Gem::Specification.new do |s|
  s.name          = "elastic-engine"
  s.version       = ElasticEngine::Version::VERSION
  s.authors       = ["Steven Podlecki"]
  s.email         = ["spodlecki@gmail.com"]
  s.description   = "Faceted Search Helper for ElasticSearch."
  s.summary       = "Faceted Search Helper for ElasticSearch."
  s.homepage      = "https://github.com/viperdezigns/elastic-engine/"
  s.license       = "Apache 2"

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.extra_rdoc_files  = [ "README.md", "LICENSE.txt" ]
  s.rdoc_options      = [ "--charset=UTF-8" ]

  s.add_dependency "elasticsearch",       '~> 0.4'
  s.add_dependency "hashie"

  s.add_development_dependency "bundler", "~> 1.3"
  s.add_development_dependency "rake"
  s.add_development_dependency "rails", "3.2.16"
  s.add_development_dependency "elasticsearch-ruby"
  s.add_development_dependency "elasticsearch-extensions"
  s.add_development_dependency "elasticsearch-model"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "activesupport", "> 3.0"
  s.add_development_dependency "activemodel",   "> 3.0"
  s.add_development_dependency "activerecord",  "> 3.0"
  s.add_development_dependency "rspec"
  s.add_development_dependency "oj"
  s.add_development_dependency "kaminari"

  s.add_development_dependency "shoulda-context"
  s.add_development_dependency "mocha"
  s.add_development_dependency "turn"
  s.add_development_dependency "yard"
  s.add_development_dependency "ruby-prof"
  s.add_development_dependency "pry"
  s.add_development_dependency "ci_reporter"

  if defined?(RUBY_VERSION) && RUBY_VERSION > '1.9'
    s.add_development_dependency "simplecov"
    s.add_development_dependency "cane"
    s.add_development_dependency "require-prof"
    s.add_development_dependency "coveralls"
  end
end
