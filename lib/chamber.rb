# frozen_string_literal: true

require 'chamber/rubinius_fix'
require 'chamber/instance'
require 'chamber/rails'

module  Chamber
  attr_writer :instance

  def load(**args)
    self.instance = Instance.new(**args)
  end

  def to_s(**args)
    return '' unless @instance

    instance.to_s(**args)
  end

  def env
    instance.settings
  end

  def instance
    @instance ||= Instance.new
  end

  def method_missing(name, *args)
    return instance.public_send(name, *args) if instance.respond_to?(name)

    super
  end

  def decrypt(value, **args)
    instance.decrypt(value, **args)
  end

  def encrypt(value, **args)
    instance.encrypt(value, **args)
  end

  def respond_to_missing?(name, include_private = false)
    instance.respond_to?(name, include_private)
  end

  module_function :decrypt,
                  :encrypt,
                  :env,
                  :instance,
                  :instance=,
                  :load,
                  :method_missing,
                  :respond_to_missing?,
                  :to_s
end
