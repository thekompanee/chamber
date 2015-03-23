require 'pathname'
require 'socket'
require 'hashie/mash'
require 'chamber/decryption_key'

module  Chamber
class   ContextResolver
  def initialize(options = {})
    self.options = Hashie::Mash.new(options)
  end

  # rubocop:disable Metrics/AbcSize
  def resolve
    options[:rootpath]       ||= Pathname.pwd
    options[:rootpath]         = Pathname.new(options[:rootpath])
    options[:encryption_key]   = resolve_encryption_key(options[:encryption_key])
    options[:decryption_key]   = resolve_decryption_key(options[:decryption_key])
    options[:namespaces]     ||= []
    options[:preset]         ||= resolve_preset

    if options[:preset] == 'rails'
      options[:basepath]     ||= options[:rootpath] + 'config'

      if options[:namespaces] == []
        require options[:rootpath].join('config', 'application').to_s

        options[:namespaces]   = [
          ::Rails.env,
          Socket.gethostname,
        ]
      end
    else
      options[:basepath]     ||= options[:rootpath]
    end

    options[:basepath]         = Pathname.new(options[:basepath])

    options[:files]          ||= [options[:basepath] + 'settings*.yml',
                                  options[:basepath] + 'settings']

    options
  rescue LoadError
    options
  end
  # rubocop:enable Metrics/AbcSize

  def self.resolve(options = {})
    new(options).resolve
  end

  protected

  attr_accessor :options

  def resolve_preset
    'rails' if in_a_rails_project?
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

  def rails_executable_exists?
    options[:rootpath].join('bin',    'rails').exist? ||
    options[:rootpath].join('script', 'rails').exist? ||
    options[:rootpath].join('script', 'console').exist?
  end
end
end
