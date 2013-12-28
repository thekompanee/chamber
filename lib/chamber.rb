require 'singleton'
require 'forwardable'
require 'yaml'
require 'hashie/mash'

class Chamber
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
    self.basepath = options.fetch(:basepath)

    load_file_with_namespaces(self.basepath, 'settings.yml', namespaces)
    load_directory("#{self.basepath}/settings")
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
    environment_hash = {}

    settings_hash.each_pair do |key, value|
      environment_keys = parent_keys.dup.push(key)
      environment_key  = environment_keys.join('_').upcase

      if value.respond_to? :each_pair
        environment_hash.merge! to_environment(value, environment_keys)
      else
        environment_hash.merge!( environment_key => value.to_s )
      end
    end

    environment_hash
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

  def load_directory(directory)
    Dir[directory + '/*.yml'].each do |file|
      dirname   = Pathname.new(File.dirname(file))
      filename  = File.basename(file)

      load_file_with_namespaces(dirname, filename, namespaces) unless filename.match(/\-/)
    end
  end

  def with_existing_environment(settings_hash = self.settings, parent_keys = [])
    environment_hash = {}

    settings_hash.each_pair do |key, value|
      environment_keys = parent_keys.dup.push(key)
      environment_key  = environment_keys.join('_').upcase

      if value.respond_to? :each_pair
        environment_hash.merge!( key => with_existing_environment(value, environment_keys) )
      else
        environment_hash.merge!( key => (ENV[environment_key] || value) )
      end
    end

    environment_hash
  end
end
