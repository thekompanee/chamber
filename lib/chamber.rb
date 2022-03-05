# frozen_string_literal: true

require 'chamber/rubinius_fix'
require 'chamber/instance'
require 'chamber/rails'

module  Chamber
  attr_writer :instance

  def load(**args)
    self.instance = Instance.new(**args)
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

  module_function :[],
                  :configuration,
                  :decrypt,
                  :dig!,
                  :dig,
                  :encrypt,
                  :filenames,
                  :files,
                  :instance,
                  :instance=,
                  :load,
                  :namespaces,
                  :respond_to_missing?,
                  :secure,
                  :sign,
                  :to_environment,
                  :to_hash,
                  :to_s,
                  :verify
end
