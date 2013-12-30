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

  def self.namespaces(*args)
    args.each do |namespace|
      self.instance.add_namespace(namespace)
    end
  end

  def load(options)
    self.settings.clear
    self.basepath = Pathname.new(options.fetch(:basepath))

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

  def namespaces
    @namespaces ||= []
  end

  def settings
    @settings ||= Hashie::Mash.new
  end

  def add_namespace(namespace)
    namespaces.push(namespace).uniq!
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

    load_file(basefile)

    namespaces.each do |namespace|
      namespace_value     = self.public_send(namespace)
      namespaced_filename = filename.gsub(extension, "-#{namespace_value}#{extension}")
      namespaced_filepath = basefile.dirname + namespaced_filename

      load_file(namespaced_filepath)
    end
  end

  def load_file(file_path)
    settings.merge! processed_settings(file_path)
  end

  def processed_settings(file_path)
    file_contents      = File.read(file_path.to_s)
    erb_result         = ERB.new(file_contents).result
    yaml_contents      = YAML.load(erb_result)

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
        { key => (ENV[environment_key] || value) }
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
end
end
