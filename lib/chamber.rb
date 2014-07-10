unless Pathname.new('foo').respond_to? :write
  class Pathname
    def write(*args)
      IO.write @path, *args
    end
  end
end

require 'chamber/instance'
require 'chamber/rails'

module  Chamber
  extend self

  def load(options = {})
    self.instance = Instance.new(options)
  end

  def to_s(options = {})
    instance.to_s(options)
  end

  def env
    instance.settings
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
    return instance.public_send(name, *args) if instance.respond_to?(name)

    super
  end

  def respond_to_missing?(name, include_private = false)
    instance.respond_to?(name, include_private)
  end
end
