# frozen_string_literal: true
require 'stringio'

module  Chamber
class   DecryptionKey
  def initialize(options = {})
    self.rootpath = options[:rootpath]
    self.filename = options[:filename] || ''
  end

  def resolve
    if filename.readable?
      filename.read
    elsif in_environment_variable?
      environment_variable
    end
  end

  def self.resolve(*args)
    new(*args).resolve
  end

  protected

  attr_accessor :filename,
                :rootpath

  def filename=(other)
    other_file = Pathname.new(other)

    @filename = if other_file.readable?
                  other_file
                else
                  default_file
                end
  end

  private

  def in_environment_variable?
    ENV['CHAMBER_KEY']
  end

  def environment_variable
    ENV['CHAMBER_KEY']
  end

  def default_file
    Pathname.new(rootpath + '.chamber.pem')
  end
end
end
