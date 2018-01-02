# frozen_string_literal: true

require 'chamber/configuration'
require 'chamber/file_set'
require 'chamber/settings'

module  Chamber
class   Instance
  attr_accessor :configuration,
                :files

  def initialize(options = {})
    self.configuration = Configuration.new  options
    self.files         = FileSet.new        configuration.to_hash
  end

  def settings
    @settings ||= files.to_settings { |settings| @settings = settings }
  end

  def filenames
    files.filenames
  end

  def secure
    files.secure
  end

  def encrypt(data, options = {})
    config = configuration.to_hash.merge(options)

    Settings.
      new(
      config.merge(
        settings:     data,
        pre_filters:  [Filters::EncryptionFilter],
        post_filters: [],
      ),
    ).
      to_hash
  end

  def decrypt(data, options = {})
    config = configuration.to_hash.merge(options)

    Settings.
      new(
      config.merge(
        settings:     data,
        pre_filters:  [Filters::NamespaceFilter],
        post_filters: [
                        Filters::DecryptionFilter,
                        Filters::FailedDecryptionFilter,
                      ],
      ),
    ).
      to_hash
  end

  def to_s(options = {})
    settings.to_s(options)
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
