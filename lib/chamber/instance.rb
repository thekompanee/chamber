# frozen_string_literal: true

require 'chamber/configuration'
require 'chamber/file_set'
require 'chamber/settings'

module  Chamber
class   Instance
  attr_accessor :configuration,
                :files

  def initialize(**args)
    self.configuration = Configuration.new(**args)
    self.files         = FileSet.new(**configuration.to_hash)
  end

  def settings
    @settings ||= files.to_settings { |settings| @settings = settings }
  end

  def [](key)
    settings.[](key)
  end

  def dig!(*args)
    settings.dig!(*args)
  end

  def dig(*args)
    settings.dig(*args)
  end

  def filenames
    files.filenames
  end

  def secure
    files.secure
  end

  def sign
    files.sign
  end

  def verify
    files.verify
  end

  def to_environment
    settings.to_environment
  end

  def to_s(**args)
    settings.to_s(**args)
  end

  def to_hash
    settings.to_hash
  end

  def namespaces
    settings.namespaces
  end

  def encrypt(data, **args)
    config = configuration.to_hash.merge(**args)

    Settings
      .new(
        **config.merge(
          settings:     data,
          pre_filters:  [Filters::EncryptionFilter],
          post_filters: [],
        ),
      )
      .to_hash
  end

  def decrypt(data, **args)
    config = configuration.to_hash.merge(**args)

    Settings
      .new(
        **config.merge(
          settings:     data,
          pre_filters:  [Filters::NamespaceFilter],
          post_filters: [
                          Filters::DecryptionFilter,
                          Filters::FailedDecryptionFilter,
                        ],
        ),
      )
      .to_hash
  end

  def method_missing(name, *args)
    return settings.public_send(name, *args) if settings.respond_to?(name)

    super
  end

  def respond_to_missing?(name, include_private = false)
    settings.respond_to?(name, include_private)
  end
end
end
