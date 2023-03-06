# frozen_string_literal: true

module  Chamber
module  Keys
class   Base
  attr_accessor :rootpath
  attr_reader   :filenames,
                :namespaces

  def self.resolve(**args)
    new(**args).resolve
  end

  def initialize(rootpath:, namespaces:, filenames: nil)
    self.rootpath   = Pathname.new(rootpath)
    self.namespaces = namespaces
    self.filenames  = filenames
  end

  def resolve
    key_paths.each_with_object({}) do |path, memo|
      namespace = namespace_from_path(path) || '__default'
      value     = if path.readable?
                    path.read
                  else
                    ENV.fetch(environment_variable_from_path(path), nil)
                  end

      memo[namespace.downcase.to_sym] = value if value
    end
  end

  def as_environment_variables
    key_paths.select(&:readable?).each_with_object({}) do |path, memo|
      memo[environment_variable_from_path(path)] = path.read
    end
  end

  private

  def key_paths
    @key_paths = (filenames.any? ? filenames : [default_key_file_path]) +
                 namespaces.map { |n| namespace_to_key_path(n) }
  end

  # rubocop:disable Performance/MapCompact
  def filenames=(other)
    @filenames = Array(other)
                   .map { |o| Pathname.new(o) }
                   .compact
  end
  # rubocop:enable Performance/MapCompact

  def namespaces=(other)
    @namespaces = other + %w{signature}
  end

  def namespace_from_path(path)
    path
      .basename
      .to_s
      .match(self.class::NAMESPACE_PATTERN) { |m| m[1].upcase }
  end

  def namespace_to_key_path(namespace)
    rootpath + ".chamber.#{namespace.to_s.tr('.-', '')}#{key_filename_extension}"
  end

  def default_key_file_path
    Pathname.new(rootpath + ".chamber#{key_filename_extension}")
  end
end
end
end
