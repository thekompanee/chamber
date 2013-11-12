# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chamber/version'

Gem::Specification.new do |spec|
  spec.name          = "chamber"
  spec.version       = Chamber::VERSION
  spec.authors       = ["stevenhallen", "m5rk"]
  spec.email         = ["mark@stevenhallen.com"]
  spec.description   = <<-CHAMBER
Chamber lets you source your Settings from an arbitrary number
of YAML files and provides a simple mechanism for overriding
settings from the ENV, which is friendly to how Heroku addons
work.
CHAMBER

  spec.summary       = "Heroku-friendly Settings"
  spec.homepage      = "http://github.com/stevenhallen/chamber"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "hashie", "~> 2.0"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.14"
  spec.add_development_dependency "simplecov", "~> 0.7"
end
