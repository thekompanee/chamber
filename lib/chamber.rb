# frozen_string_literal: true

require 'chamber/rubinius_fix'
require 'chamber/instance'
require 'chamber/rails'

module  Chamber
  attr_writer :instance

  def load(options = {})
    self.instance = Instance.new(options)
  end

  def to_s(options = {})
    return '' unless @instance

    instance.to_s(options)
  end

  def env
    instance.settings
  end

  def instance
    @instance ||= Instance.new({})
  end

  def method_missing(name, *args)
    return instance.public_send(name, *args) if instance.respond_to?(name)

    super
  end

  def respond_to_missing?(name, include_private = false)
    instance.respond_to?(name, include_private)
  end

  module_function :load,
                  :to_s,
                  :env,
                  :instance,
                  :instance=,
                  :method_missing,
                  :respond_to_missing?
end
