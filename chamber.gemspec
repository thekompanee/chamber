# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chamber/version'

Gem::Specification.new do |spec|
  spec.rubygems_version           = '1.3.5'

  spec.name                       = 'chamber'
  spec.rubyforge_project          = 'chamber'

  spec.version                    = Chamber::VERSION
  spec.platform                   = Gem::Platform::RUBY

  spec.authors                    = ['stevenhallen', 'm5rk', 'thekompanee', 'jfelchner']
  spec.email                      = 'mark@stevenhallen.com'
  spec.date                       = Time.now
  spec.homepage                   = 'https://github.com/m5rk/chamber'

  spec.summary                    = "A surprisingly configurable convention-based approach to managing your application's custom configuration settings."
  spec.description                = <<-CHAMBER
Chamber lets you source your Settings from an arbitrary number of YAML files and
provides a simple mechanism for overriding settings from the ENV, which is
friendly to how Heroku addons work.
CHAMBER

  spec.rdoc_options               = ['--charset', 'UTF-8']
  spec.extra_rdoc_files           = %w[README.md LICENSE]

  #= Manifest =#
  spec.files                      = Dir.glob('{lib,templates}/**/*')
  spec.test_files                 = Dir.glob('{test,spec,features}/**/*')
  spec.executables                = Dir.glob('bin/*').map{ |f| File.basename(f) }
  spec.require_paths              = ['lib']

  spec.add_runtime_dependency     'thor',                       '~> 0.18.1'
  spec.add_runtime_dependency     'hashie',                     '~> 2.0'

  spec.add_development_dependency 'rspec',                      '~> 3.0.0.beta'
  spec.add_development_dependency 'rspectacular',               '~> 0.23.0'
  spec.add_development_dependency 'codeclimate-test-reporter',  '~> 0.3.0'
end
