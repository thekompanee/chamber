require 'chamber/instance'
require 'chamber/rails'

module  Chamber
  extend self

  def load(options = {})
    self.instance = Instance.new(options)
  end

  def filenames
    instance.files.filenames
  end

  def files
    instance.files
  end

  def to_s
    instance.settings.to_s
  end

  def env
    instance.settings
  end

  def config
    instance.configuration
  end

  protected

  def instance
    @@instance ||= Instance.new({})
  end

  def instance=(new_instance)
    @@instance = new_instance
  end

  public

  def method_missing(name, *args)
    return instance.settings.public_send(name, *args) if instance.settings.respond_to?(name)

    super
  end

  def respond_to_missing?(name, include_private = false)
    instance.settings.respond_to?(name, include_private)
  end
end
