require 'hashie/mash'
require 'chamber/system_environment'
require 'chamber/namespace_set'
require 'chamber/filters/namespace_filter'
require 'chamber/filters/decryption_filter'
require 'chamber/filters/environment_filter'
require 'chamber/filters/boolean_conversion_filter'

###
# Internal: Represents the base settings storage needed for Chamber.
#
class   Chamber
class   Settings

  attr_reader :namespaces

  def initialize(options = {})
    self.filters    = options.fetch(:filters,     [
                                                    Filters::NamespaceFilter,
                                                            Filters::DecryptionFilter,
                                                    Filters::EnvironmentFilter,
                                                    Filters::BooleanConversionFilter,
                                                  ])
    self.namespaces = options.fetch(:namespaces,  NamespaceSet.new)
    self.decryption_key = options.fetch(:decryption_key,  nil)
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
  # Returns a Hash sorted alphabetically by the names of the keys
  #
  def to_environment
    Hash[SystemEnvironment.extract_from(data).sort]
  end

  ###
  # Internal: Converts a Settings object into a String with a format that will
  # work well when working with the shell.
  #
  # Examples:
  #
  #   Settings.new( settings: {
  #                   my_key:       'my value',
  #                   my_other_key: 'my other value',
  #                 } ).to_s
  #   # => 'MY_KEY="my value" MY_OTHER_KEY="my other value"'
  #
  def to_s(options = {})
    pair_separator       = options[:pair_separator]       || ' '
    value_surrounder     = options[:value_surrounder]     || '"'
    name_value_separator = options[:name_value_separator] || '='

    pairs = to_environment.to_a.map do |pair|
      %Q{#{pair[0]}#{name_value_separator}#{value_surrounder}#{pair[1]}#{value_surrounder}}
    end

    pairs.join(pair_separator)
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

  ###
  # Internal: Returns the Settings data as a Hash for easy manipulation.
  # Changes made to the hash will *not* be reflected in the original Settings
  # object.
  #
  # Returns a Hash
  #
  def to_hash
    data.dup
  end

  def method_missing(name, *args)
    return data.public_send(name, *args) if data.respond_to?(name)

    super
  end

  def respond_to_missing?(name, include_private = false)
    data.respond_to?(name, include_private)
  end

  protected

  attr_accessor :filters,
                :decryption_key
  attr_reader   :raw_data
  attr_writer   :namespaces

  def data
    @data ||= Hashie::Mash.new
  end

  def data=(raw_data)
    @raw_data = Hashie::Mash.new(raw_data)
    @data     = filters.reduce(raw_data) do |filtered_data, filter|
                  filter.execute( data:           filtered_data,
                                  namespaces:     self.namespaces,
                                  decryption_key: self.decryption_key)
                end
  end
end
end
