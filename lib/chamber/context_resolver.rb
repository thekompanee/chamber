# frozen_string_literal: true
require 'pathname'
require 'socket'
require 'chamber/hashie_mash'
require 'chamber/decryption_key'

module  Chamber
class   ContextResolver
  def initialize(options = {})
    self.options = HashieMash.new(options)
  end

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity, Metrics/MethodLength
  def resolve
    options[:rootpath]       ||= Pathname.pwd
    options[:rootpath]         = Pathname.new(options[:rootpath])
    options[:encryption_key]   = resolve_encryption_key(options[:encryption_key])
    options[:decryption_key]   = resolve_decryption_key(options[:decryption_key])
    options[:namespaces]     ||= []
    options[:preset]         ||= resolve_preset

    if %w{rails rails-engine}.include?(options[:preset])
      if options[:preset] == 'rails-engine'
        engine_spec_dummy_directory = options[:rootpath] + 'spec' + 'dummy'
        engine_test_dummy_directory = options[:rootpath] + 'test' + 'dummy'

        options[:rootpath] = if (engine_spec_dummy_directory + 'config.ru').exist?
                               engine_spec_dummy_directory
                             elsif (engine_test_dummy_directory + 'config.ru').exist?
                               engine_test_dummy_directory
                             end
      end

      options[:basepath]     ||= options[:rootpath] + 'config'

      if options[:namespaces] == []
        require options[:rootpath].join('config', 'application').to_s

        options[:namespaces] = [
                                 ::Rails.env,
                                 Socket.gethostname,
                               ]
      end
    else
      options[:basepath] ||= options[:rootpath]
    end

    options[:basepath]         = Pathname.new(options[:basepath])

    options[:files]          ||= [
                                   options[:basepath] + 'settings*.yml',
                                   options[:basepath] + 'settings',
                                 ]

    options
  rescue LoadError
    options
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity, Metrics/MethodLength

  def self.resolve(options = {})
    new(options).resolve
  end

  protected

  attr_accessor :options

  def resolve_preset
    if in_a_rails_project?
      'rails'
    elsif in_a_rails_engine?
      'rails-engine'
    end
  end

  def resolve_encryption_key(key)
    key ||= options[:rootpath] + '.chamber.pub.pem'

    key if Pathname.new(key).readable?
  end

  def resolve_decryption_key(key)
    DecryptionKey.resolve(filename: key,
                          rootpath: options[:rootpath])
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
end
end
