# frozen_string_literal: true

require 'chamber/rubinius_fix'
require 'chamber/instance'
require 'chamber/rails'

module  Chamber
  attr_writer :instance

  def load(**args)
    self.instance = Instance.new(**args)
  end

  def env
    instance.settings
  end

  def instance
    @instance ||= Instance.new
  end

  def [](key)
    instance.[](key)
  end

  def dig!(*args)
    instance.dig!(*args)
  end

  def dig(*args)
    instance.dig(*args)
  end

  def configuration
    instance.configuration
  end

  def decrypt(value, **args)
    instance.decrypt(value, **args)
  end

  def encrypt(value, **args)
    instance.encrypt(value, **args)
  end

  def files
    instance.files
  end

  def filenames
    instance.filenames
  end

  def namespaces
    instance.namespaces
  end

  def secure
    instance.secure
  end

  def sign
    instance.sign
  end

  def verify
    instance.verify
  end

  def to_environment
    instance.to_environment
  end

  def to_hash
    instance.to_hash
  end

  def to_s(**args)
    return '' unless @instance

    instance.to_s(**args)
  end

  def method_missing(name, *args)
    return instance.public_send(name, *args) if instance.respond_to?(name)

    super
  end

  def respond_to_missing?(name, include_private = false)
    instance.respond_to?(name, include_private)
  end

  module_function :[],
                  :configuration,
                  :decrypt,
                  :dig!,
                  :dig,
                  :encrypt,
                  :env,
                  :filenames,
                  :files,
                  :instance,
                  :instance=,
                  :load,
                  :method_missing,
                  :namespaces,
                  :respond_to_missing?,
                  :secure,
                  :sign,
                  :to_environment,
                  :to_hash,
                  :to_s,
                  :verify
end
