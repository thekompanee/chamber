require 'chamber/configuration'
require 'chamber/rails'

module  Chamber
  def self.load(options = {})
    self.config = Configuration.new(options)
  end

  def self.filenames
    config.files.filenames
  end

  def self.to_s
    config.to_s
  end

  def self.env
    config.settings
  end

class << self
  attr_reader   :config

  protected

  attr_writer   :config

  def method_missing(name, *args)
    return config.settings.public_send(name, *args) if config.settings.respond_to?(name)

    super
  end

  def respond_to_missing?(name, include_private = false)
    config.settings.respond_to?(name, include_private)
  end
end
end
