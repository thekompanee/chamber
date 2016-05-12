# frozen_string_literal: true
require 'chamber/configuration'
require 'chamber/file_set'

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
