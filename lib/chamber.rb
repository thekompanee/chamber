require 'singleton'
require 'forwardable'
require 'yaml'
require 'hashie/mash'

class Chamber
  include Singleton

  class << self
    extend Forwardable

    def_delegators :instance, :load,
                              :basepath,
                              :[]

    alias_method :env, :instance
  end

  attr_accessor :basepath,
                :settings,
                :namespaces

  def self.namespaces(*args)
    args.each do |namespace|
      self.instance.add_namespace(namespace)
    end
  end

  def load(options)
    self.settings.clear
    self.basepath = options.fetch(:basepath)

    load_file_with_namespaces(self.basepath, 'settings.yml', namespaces)
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
      namespaced_filepath = basepath + namespaced_filename

      load_file(namespaced_filepath)
    end
  end

  def load_file(file_path)
    file_contents      = File.read(file_path.to_s)
    erb_result         = ERB.new(file_contents).result
    yaml_contents      = YAML.load(erb_result)

    processed_settings = with_existing_environment(yaml_contents)

    settings.merge! processed_settings
  rescue Errno::ENOENT
    # If a settings file does not exist, ignore it
  end

  def with_existing_environment(yaml_hash, parent_keys = [])
    yaml_hash        = yaml_hash.dup

    yaml_hash.each_pair do |key, value|
      environment_keys = parent_keys.dup.push(key)

      if value.respond_to? :each_pair
        yaml_hash[key] = with_existing_environment(value, environment_keys)
      else
        environment_key = environment_keys.join('_').upcase

        yaml_hash[key] = ENV[environment_key] || value
      end
    end

    yaml_hash
  end
end
