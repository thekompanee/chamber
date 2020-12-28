# frozen_string_literal: true

require 'pathname'
require 'socket'

require 'chamber/core_ext/hash'
require 'chamber/keys/decryption'
require 'chamber/keys/encryption'

module  Chamber
class   ContextResolver
  attr_accessor :options

  def initialize(options = {})
    self.options = options.transform_keys(&:to_sym)
  end

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize, Layout/LineLength
  def resolve
    options[:rootpath]   ||= Pathname.pwd
    options[:rootpath]     = Pathname.new(options[:rootpath])
    options[:namespaces] ||= []
    options[:preset]     ||= resolve_preset

    if %w{rails rails-engine}.include?(options[:preset])
      options[:rootpath]     = detect_engine_root                                if options[:preset]     == 'rails-engine'
      options[:namespaces]   = load_rails_default_namespaces(options[:rootpath]) if options[:namespaces] == []
      options[:basepath]   ||= options[:rootpath] + 'config'
    else
      options[:basepath]   ||= options[:rootpath]
    end

    options[:namespaces]        = resolve_namespaces(options[:namespaces])
    options[:encryption_keys]   = Keys::Encryption.resolve(filenames:  options[:encryption_keys],
                                                           namespaces: options[:namespaces],
                                                           rootpath:   options[:rootpath])
    options[:decryption_keys]   = Keys::Decryption.resolve(filenames:  options[:decryption_keys],
                                                           namespaces: options[:namespaces],
                                                           rootpath:   options[:rootpath])
    options[:basepath]          = Pathname.new(options[:basepath])
    options[:files]           ||= [
                                    options[:basepath] + 'settings*.yml',
                                    options[:basepath] + 'settings',
                                  ]

    options[:signature_name]    = options[:signature_name]

    options
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize, Layout/LineLength

  def self.resolve(options = {})
    new(options).resolve
  end

  protected

  def resolve_namespaces(other)
    (other.respond_to?(:values) ? other.values : other)
      .map do |namespace|
        namespace.respond_to?(:call) ? namespace.call : namespace
      end
  end

  def resolve_preset
    if in_a_rails_project?
      'rails'
    elsif in_a_rails_engine?
      'rails-engine'
    end
  end

  def in_a_rails_project?
    (options[:rootpath] + 'config.ru').exist? &&
    rails_executable_exists?
  end

  def in_a_rails_engine?
    (options[:rootpath] + 'spec' + 'dummy' + 'config.ru').exist? ||
    (options[:rootpath] + 'test' + 'dummy' + 'config.ru').exist?
  end

  def rails_executable_exists?
    options[:rootpath].join('bin',    'rails').exist? ||
    options[:rootpath].join('script', 'rails').exist? ||
    options[:rootpath].join('script', 'console').exist?
  end

  private

  def detect_engine_root
    engine_spec_dummy_directory = options[:rootpath] + 'spec' + 'dummy'
    engine_test_dummy_directory = options[:rootpath] + 'test' + 'dummy'

    if (engine_spec_dummy_directory + 'config.ru').exist?
      engine_spec_dummy_directory
    elsif (engine_test_dummy_directory + 'config.ru').exist?
      engine_test_dummy_directory
    end
  end

  def load_rails_default_namespaces(root)
    require root.join('config', 'application').to_s

    [
      ::Rails.env,
      Socket.gethostname,
    ]
  rescue LoadError
    []
  end
end
end
