# frozen_string_literal: true

require 'pathname'
require 'stringio'

module  Chamber
class   EncryptionKey
  NAMESPACE_PATTERN = /
                        \A          # Beginning of Filename
                        \.          # Initial Period
                        [^\.]+?     # Initial Key Filename Base
                        \.          # Dot Separator
                        (\w+)       # Namespace
                        \.pub\.pem  # Post Namespace Extension
                      /x

  def self.resolve(*args)
    new(*args).resolve
  end

  attr_accessor :namespaces,
                :rootpath
  attr_reader   :filenames

  def initialize(options = {})
    self.rootpath   = options.fetch(:rootpath)
    self.namespaces = options.fetch(:namespaces)
    self.filenames  = (
                        Array(options[:filenames]) +
                        generate_key_filenames
                      ).
                        uniq
  end

  def resolve
    filenames.each_with_object({}) do |filename, memo|
      namespace = namespace_from_filename(filename) || 'default'
      value     = key_from_file_contents(filename)        ||
                  key_from_environment_variable(filename) ||
                  fail(ArgumentError,
                       "One or more of your keys were not found: #{filename}")

      memo[namespace.downcase.to_sym] = value
    end
  end

  def filenames=(other)
    @filenames = other.map { |o| Pathname.new(o) }
  end

  private

  def key_from_file_contents(filename)
    filename.readable? && filename.read
  end

  def key_from_environment_variable(filename)
    ENV[environment_variable_from_filename(filename)]
  end

  def environment_variable_from_filename(filename)
    [
      'CHAMBER',
      namespace_from_filename(filename),
      'PUBLIC_KEY',
    ].
      compact.
      join('_')
  end

  def namespace_from_filename(filename)
    filename.
      basename.
      to_s.
      match(NAMESPACE_PATTERN) { |m| m[1].upcase }
  end

  def generate_key_filenames
    namespaces.map do |namespace|
      rootpath + ".chamber.#{namespace}.pub.pem"
    end
  end

  def default_encryption_key_file_path
    Pathname.new(rootpath + '.chamber.pub.pem')
  end
end
end
