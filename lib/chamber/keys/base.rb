# frozen_string_literal: true

module  Chamber
module  Keys
class   Base
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
      value     = key_from_file_contents(filename) ||
                  key_from_environment_variable(filename)

      memo[namespace.downcase.to_sym] = value if value
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

  def namespace_from_filename(filename)
    filename.
      basename.
      to_s.
      match(self.class::NAMESPACE_PATTERN) { |m| m[1].upcase }
  end
end
end
end
