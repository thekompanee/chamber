require 'hashie/mash'
require 'chamber/system_environment'
require 'chamber/namespace_set'

###
# Internal: Represents the base settings storage needed for Chamber.
#
class   Chamber
class   Settings

  attr_reader :namespaces

  def initialize(options = {})
    self.namespaces = options.fetch(:namespaces,  NamespaceSet.new)
    self.data       = options.fetch(:settings,    Hashie::Mash.new)
  end

  ###
  # Internal: Converts a Settings object into a hash that is compatible as an
  # environment variable hash.
  #
  # Example:
  #
  #   settings = Settings.new settings: {
  #                             my_setting:     'my value',
  #                             my_sub_setting: {
  #                               my_sub_sub_setting_1: 'my sub value 1',
  #                               my_sub_sub_setting_2: 'my sub value 2',
  #                             }
  #   settings.to_environment
  #   # => {
  #     'MY_SETTING'                          => 'my value',
  #     'MY_SUB_SETTING_MY_SUB_SUB_SETTING_1' => 'my sub value 1',
  #     'MY_SUB_SETTING_MY_SUB_SUB_SETTING_2' => 'my sub value 2',
  #   }
  #
  # Returns a Hash
  #
  def to_environment
    SystemEnvironment.extract_from(data)
  end

  ###
  # Internal: Merges a Settings object with another Settings object or
  # a hash-like object.
  #
  # Also, if merging Settings, it will merge the namespaces as well.
  #
  # Example:
  #
  #   settings        = Settings.new settings: { my_setting:        'my value' }
  #   other_settings  = Settings.new settings: { my_other_setting:  'my other value' }
  #
  #   settings.merge! other_settings
  #
  #   settings
  #   # => {
  #     'my_setting'        => 'my value',
  #     'my_other_setting'  => 'my other value',
  #   }
  #
  # Returns a Hash
  #
  def merge!(other)
    self.data       = data.merge(other.to_hash)
    self.namespaces = (namespaces + other.namespaces) if other.respond_to? :namespaces
  end

  def eql?(other)
    other.is_a?(        Chamber::Settings)  &&
    self.data        == other.data          &&
    self.namespaces  == other.namespaces
  end

  def to_hash
    data
  end

  def method_missing(name, *args)
    return data.public_send(name, *args) if data.respond_to?(name)

    super
  end

  def respond_to_missing?(name, include_private = false)
    data.respond_to?(name, include_private)
  end

  protected

  attr_reader :raw_data
  attr_writer :namespaces

  def data
    @data ||= Hashie::Mash.new
  end

  def data=(raw_data)
    @raw_data = Hashie::Mash.new(raw_data)

    namespace_checked_data =  if data_is_namespaced?
                                namespace_filtered_data
                              else
                                self.raw_data
                              end

    @data = SystemEnvironment.inject_into(namespace_checked_data)
  end

  private

  def data_is_namespaced?
    @data_is_namespaced ||= raw_data.keys.any? { |key| namespaces.include? key }
  end

  def namespace_filtered_data
    @namespace_filtered_data ||= -> do
      data = Hashie::Mash.new

      namespaces.each do |namespace|
        data.merge!(raw_data[namespace]) if raw_data[namespace]
      end

      data
    end.call
  end
end
end
