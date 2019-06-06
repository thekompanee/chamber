# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chamber/version'

Gem::Specification.new do |spec|
  spec.name          = 'chamber'
  spec.version       = Chamber::VERSION
  spec.authors       = ['thekompanee', 'jfelchner', 'stevenhallen', 'm5rk']
  spec.email         = ['hello@thekompanee.com']
  spec.summary       = %q{A surprisingly configurable convention-based approach to managing your application's custom configuration settings.}
  spec.description   = %q{Chamber lets you source your Settings from an arbitrary number of YAML files and provides a simple mechanism for overriding settings from the ENV, which is friendly to how Heroku addons work.}
  spec.homepage      = 'https://github.com/thekompanee/chamber'
  spec.licenses      = ['MIT']

  spec.cert_chain    = ['certs/thekompanee.pem']
  spec.signing_key   = File.expand_path('~/.gem/certs/thekompanee-private_key.pem') if $0 =~ /gem\z/

  spec.executables   = ['chamber']
  spec.files         = Dir['{app,config,db,lib,templates}/**/*'] + %w{README.md LICENSE.txt}

  spec.metadata      = {
    'allowed_push_host' => 'https://rubygems.org',
    'bug_tracker_uri'   => 'https://github.com/thekompanee/chamber/issues',
    'changelog_uri'     => 'https://github.com/thekompanee/chamber/blob/master/CHANGELOG.md',
    'documentation_uri' => 'https://github.com/thekompanee/chamber/tree/releases/v2.13.0',
    'homepage_uri'      => 'https://github.com/thekompanee/chamber',
    'source_code_uri'   => 'https://github.com/thekompanee/chamber',
    'wiki_uri'          => 'https://github.com/thekompanee/chamber/wiki',
  }

  spec.add_dependency             'thor',          [">= 0.19.1", "< 0.21"]
  spec.add_dependency             'hashie',        ["~> 3.3"]

  spec.add_development_dependency 'rspec',         ["~> 3.5"]
  spec.add_development_dependency 'rspectacular',  ["~> 0.46"]
  spec.add_development_dependency 'activerecord',  ["~> 4.0"]
  spec.add_development_dependency 'activesupport', ["~> 4.0"]
  spec.add_development_dependency 'timecop',       ["~> 0.0"]
end
