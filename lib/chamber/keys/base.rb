# frozen_string_literal: true

module  Chamber
module  Keys
class   Base
  def self.resolve(*args)
    new(*args).resolve
  end

  attr_accessor :rootpath
  attr_reader   :filenames,
                :namespaces

  def initialize(options = {})
    self.rootpath   = Pathname.new(options.fetch(:rootpath))
    self.namespaces = options.fetch(:namespaces)
    self.filenames  = options[:filenames]
  end

  def resolve
    filenames.each_with_object({}) do |filename, memo|
      namespace = namespace_from_filename(filename) || '__default'
      value     = key_from_file_contents(filename) ||
                  key_from_environment_variable(filename)

      memo[namespace.downcase.to_sym] = value if value
    end
  end

  # rubocop:disable Performance/ChainArrayAllocation
  def filenames=(other)
    @filenames = begin
                   paths = Array(other).
                             map { |o| Pathname.new(o) }.
                             compact

                   paths << default_key_file_path if paths.empty?

                   (
                     paths +
                     generate_key_filenames
                   ).
                     uniq
                 end
  end
  # rubocop:enable Performance/ChainArrayAllocation

  private

  def namespaces=(other)
    @namespaces = begin
                    keys = if other.respond_to?(:keys)
                             other.keys.map(&:to_s)
                           else
                             other
                           end

                    keys + %w{signature}
                  end
  end

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

  def generate_key_filenames
    namespaces.map do |namespace|
      rootpath + ".chamber.#{namespace.to_s.tr('.-', '')}#{key_filename_extension}"
    end
  end

  def default_key_file_path
    Pathname.new(rootpath + ".chamber#{key_filename_extension}")
  end
end
end
end
