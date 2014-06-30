require 'hashie/mash'
require 'chamber/namespace_set'
require 'chamber/filters/namespace_filter'
require 'chamber/filters/encryption_filter'
require 'chamber/filters/decryption_filter'
require 'chamber/filters/environment_filter'
require 'chamber/filters/boolean_conversion_filter'
require 'chamber/filters/secure_filter'
require 'chamber/filters/translate_secure_keys_filter'
require 'chamber/filters/insecure_filter'

###
# Internal: Represents the base settings storage needed for Chamber.
#
module  Chamber
class   Settings

  attr_reader :namespaces

  def initialize(options = {})
    self.namespaces       = options[:namespaces]      ||  []
    self.raw_data         = options[:settings]        ||  {}
    self.decryption_key   = options[:decryption_key]
    self.encryption_key   = options[:encryption_key]
    self.pre_filters      = options[:pre_filters]     ||  [
                                                            Filters::NamespaceFilter,
                                                          ]
    self.post_filters     = options[:post_filters]    ||  [
                                                            Filters::DecryptionFilter,
                                                            Filters::TranslateSecureKeysFilter,
                                                            Filters::EnvironmentFilter,
                                                            Filters::BooleanConversionFilter,
                                                          ]
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
    to_concatenated_name_hash('_').each_with_object({}) do |pair, env_hash|
      env_hash[pair[0].upcase] = pair[1].to_s
    end
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
    hierarchical_separator = options[:hierarchical_separator] || '_'
    pair_separator         = options[:pair_separator]         || ' '
    value_surrounder       = options[:value_surrounder]       || '"'
    name_value_separator   = options[:name_value_separator]   || '='

    concatenated_name_hash = to_concatenated_name_hash(hierarchical_separator)

    pairs = concatenated_name_hash.to_a.map do |key, value|
      %Q{#{key.upcase}#{name_value_separator}#{value_surrounder}#{value}#{value_surrounder}}
    end

    pairs.join(pair_separator)
  end

  ###
  # Internal: Returns the Settings data as a Hash for easy manipulation.
  # Changes made to the hash will *not* be reflected in the original Settings
  # object.
  #
  # Returns a Hash
  #
  def to_hash
    data.to_hash
  end

  ###
  # Internal: Returns a hash which contains the flattened name hierarchy of the
  # setting as the keys and the values of each setting as the value.
  #
  # Examples:
  #   Settings.new(settings: {
  #                  my_setting: 'value',
  #                  there:      'was not that easy?',
  #                  level_1:    {
  #                    level_2:    {
  #                      some_setting: 'hello',
  #                      another:      'goodbye',
  #                    },
  #                    body:       'gracias',
  #                  },
  #                }).to_flattened_name_hash
  #   # => {
  #     ['my_setting']                         => 'value',
  #     ['there']                              => 'was not that easy?',
  #     ['level_1', 'level_2', 'some_setting'] => 'hello',
  #     ['level_1', 'level_2', 'another']      => 'goodbye',
  #     ['level_1', 'body']                    => 'gracias',
  #   }
  #
  # Returns a Hash
  #
  def to_flattened_name_hash(hash = data, parent_keys = [])
    flattened_name_hash = {}

    hash.each_pair do |key, value|
      flattened_name_components = parent_keys.dup.push(key)

      if value.respond_to?(:each_pair)
        flattened_name_hash.merge! to_flattened_name_hash(value, flattened_name_components)
      else
        flattened_name_hash[flattened_name_components] = value
      end
    end

    flattened_name_hash
  end

  def to_concatenated_name_hash(hierarchical_separator = '_')
    concatenated_name_hash = {}

    to_flattened_name_hash.each_pair do |flattened_name, value|
      concatenated_name = flattened_name.join(hierarchical_separator)

      concatenated_name_hash[concatenated_name] = value
    end

    concatenated_name_hash.sort
  end

  ###
  # Internal: Merges a Settings object with another Settings object or
  # a hash-like object.
  #
  # Also, if merging Settings, it will merge all other Settings data as well.
  #
  # Example:
  #
  #   settings        = Settings.new settings: { my_setting:        'my value' }
  #   other_settings  = Settings.new settings: { my_other_setting:  'my other value' }
  #
  #   settings.merge other_settings
  #
  #   settings
  #   # => {
  #     'my_setting'        => 'my value',
  #     'my_other_setting'  => 'my other value',
  #   }
  #
  # Returns a new Settings object
  #
  def merge(other)
    other_settings = if other.is_a? Settings
                       other
                     elsif other.is_a? Hash
                       Settings.new(settings: other)
                     end

    Settings.new(
      encryption_key: encryption_key || other_settings.encryption_key,
      decryption_key: decryption_key || other_settings.decryption_key,
      namespaces:     (namespaces + other_settings.namespaces),
      settings:       raw_data.merge(other_settings.raw_data))
  end

  ###
  # Internal: Determines whether a Settings is equal to another hash-like
  # object.
  #
  # Returns a Boolean
  #
  def ==(other)
    self.to_hash == other.to_hash
  end

  ###
  # Internal: Determines whether a Settings is equal to another Settings.
  #
  # Returns a Boolean
  #
  def eql?(other)
    other.is_a?(        Chamber::Settings)  &&
    self.data        == other.data          &&
    self.namespaces  == other.namespaces
  end

  def securable
    Settings.new( metadata.merge(
                    settings:     raw_data,
                    pre_filters:  [Filters::SecureFilter]))
  end

  def secure
    Settings.new( metadata.merge(
                    settings:     raw_data,
                    pre_filters:  [Filters::EncryptionFilter],
                    post_filters: [Filters::TranslateSecureKeysFilter] ))
  end

  def insecure
    Settings.new( metadata.merge(
                    settings:     raw_data,
                    pre_filters:  [Filters::InsecureFilter],
                    post_filters: [Filters::TranslateSecureKeysFilter] ))
  end

  protected

  attr_accessor :pre_filters,
                :post_filters,
                :encryption_key,
                :decryption_key,
                :raw_data

  def raw_data=(new_raw_data)
    @raw_data   = Hashie::Mash.new(new_raw_data)
  end

  def namespaces=(raw_namespaces)
    @namespaces = NamespaceSet.new(raw_namespaces)
  end

  def raw_data
    @filtered_raw_data  ||= pre_filters.reduce(@raw_data) do |filtered_data, filter|
                              filter.execute({data: filtered_data}.
                                              merge(metadata))
                            end
  end

  def data
    @data               ||= post_filters.reduce(raw_data) do |filtered_data, filter|
                              filter.execute({data: filtered_data}.
                                              merge(metadata))
                            end
  end

  def metadata
    {
      namespaces:     self.namespaces,
      decryption_key: self.decryption_key,
      encryption_key: self.encryption_key,
    }
  end

  public

  def method_missing(name, *args)
    return data.public_send(name, *args) if data.respond_to?(name)

    super
  end

  def respond_to_missing?(name, include_private = false)
    data.respond_to?(name, include_private)
  end
end
end
