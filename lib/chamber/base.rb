require 'singleton'
require 'forwardable'
require 'yaml'
require 'hashie/mash'

module  Chamber
class   Base
  include Singleton

  class << self
    extend Forwardable

    def_delegators :instance, :[],
                              :basepath,
                              :load,
                              :namespaces,
                              :settings,
                              :to_environment

    alias_method :env, :instance
  end

  attr_accessor :basepath,
                :namespaces,
                :settings

  def load(options)
    self.settings.clear

    self.basepath   = Pathname.new(options.fetch(:basepath))
    self.namespaces = options.fetch(:namespaces, {})

    load_file_with_namespaces(self.basepath, 'credentials.yml', namespaces)
    load_file_with_namespaces(self.basepath, 'settings.yml',    namespaces)
    load_directory(self.basepath + 'settings', namespaces)
  end

  def method_missing(name, *args)
    return settings.public_send(name, *args) if settings.respond_to?(name)

    super
  end

  def respond_to_missing(name)
    settings.respond_to?(name)
  end

  def settings
    @settings ||= Hashie::Mash.new
  end

  def to_environment(settings_hash = self.settings, parent_keys = [])
    with_environment(settings_hash, parent_keys,
      ->(key, value, environment_keys) do
        to_environment(value, environment_keys)
      end,
      ->(key, value, environment_key) do
        { environment_key => value.to_s }
      end)
  end

  private

  def basepath=(pathlike)
    @basepath = Pathname.new(File.expand_path(pathlike))
  end

  def load_file_with_namespaces(path, filename, namespaces)
    basefile  = path + filename
    extension = basefile.extname

    load_file(basefile, namespaces)

    namespaces.each_pair do |namespace, callable|
      namespace_value     = callable.call
      namespaced_filename = filename.gsub(extension, "-#{namespace_value}#{extension}")
      namespaced_filepath = basefile.dirname + namespaced_filename

      load_file(namespaced_filepath, namespaces)
    end
  end

  def load_file(file_path, namespaces)
    full_settings_from_file = processed_settings(file_path)

    namespaced_settings = Hashie::Mash.new

    file_settings_are_namespaced = namespaces.any? do |namespace, callable|
                                     full_settings_from_file.has_key? callable.call
                                   end

    if file_settings_are_namespaced
      namespaces.each_pair do |namespace, callable|
        namespace_value = callable.call

        namespaced_settings.merge! full_settings_from_file.fetch(namespace_value, {})
      end
    else
      namespaced_settings = full_settings_from_file
    end

    settings.merge! namespaced_settings
  end

  def processed_settings(file_path)
    file_contents = File.read(file_path.to_s)
    erb_result    = ERB.new(file_contents).result
    yaml_contents = YAML.load(erb_result)

    with_existing_environment(yaml_contents)
  rescue Errno::ENOENT
    {}
  end

  def load_directory(directory, namespaces)
    base_filenames(directory).each do |filename|
      load_file_with_namespaces(directory, filename, namespaces)
    end
  end

  def base_filenames(directory)
    base_filenames = []

    Dir[directory + '*.yml'].each do |file|
      filename = File.basename(file)

      base_filenames << filename.sub(/\-.*(?=\.yml\z)/, '')
    end

    base_filenames.uniq
  end

  def with_existing_environment(settings_hash = self.settings, parent_keys = [])
    with_environment(settings_hash, parent_keys,
      ->(key, value, environment_keys) do
        { key => with_existing_environment(value, environment_keys) }
      end,
      ->(key, value, environment_key) do
        { key => convert_value(ENV[environment_key] || value) }
      end)
  end

  def with_environment(settings_hash, parent_keys, hash_block, value_block)
    environment_hash = {}

    settings_hash.each_pair do |key, value|
      environment_keys = parent_keys.dup.push(key)
      environment_key  = environment_keys.join('_').upcase

      if value.respond_to? :each_pair
        environment_hash.merge!(hash_block.call(key, value, environment_keys))
      else
        environment_hash.merge!(value_block.call(key, value, environment_key))
      end
    end

    environment_hash
  end

  def convert_value(value)
    return nil if value.nil?

    if value.is_a? String
      case value
      when 'false', 'f', 'no'
        false
      when 'true', 't', 'yes'
        true
      else
        value
      end
    else
      value
    end
  end
end
end
