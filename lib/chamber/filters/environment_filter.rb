# frozen_string_literal: true

require 'yaml'

require 'chamber/errors/environment_conversion'

module  Chamber
module  Filters
class   EnvironmentFilter
  attr_accessor :data,
                :secure_key_token
  ###
  # Internal: Allows the existing environment to be injected into the passed in
  # hash.  The hash that is passed in is *not* modified, instead a new hash is
  # returned.
  #
  # This filter will also do basic value conversions from the environment
  # variable string to the data type defined in the YAML.  For example if the
  # YAML value is `true`, then the conversion knows it's a Boolean.  If there's
  # an environment varible which should override that value, it will look to see
  # if it is a `String` of 'true', 'false', 't', 'f', 'yes', or 'no' and perform
  # the appropriate conversion of that value into a Boolean.
  #
  # This will work for:
  #
  #   * Booleans
  #   * Integers
  #   * Floats
  #   * Arrays
  #
  # For the Arrays, it will convert the environment value by parsing the string
  # as YAML.  Whatever the parsed value ends up being, *must* be an Array.
  #
  # Examples:
  #
  #   ###
  #   # Injects the current environment variables
  #   #
  #   ENV['LEVEL_ONE_1_LEVEL_TWO_1']               = 'env value 1'
  #   ENV['LEVEL_ONE_1_LEVEL_TWO_2_LEVEL_THREE_1'] = 'env value 2'
  #
  #   EnvironmentFilter.execute(
  #     level_one_1: {
  #       level_two_1: 'value 1',
  #       level_two_2: {
  #         level_three_1: 'value 2' } } )
  #
  #   # => {
  #     'level_one_1' => {
  #       'level_two_1' => 'env value 1',
  #       'level_two_2' => {
  #         'level_three_1' => 'env value 2',
  #   }
  #
  #   ###
  #   # Can do basic value conversions based on the raw data
  #   #
  #   ENV['LEVEL_ONE_1_LEVEL_TWO_1']               = '1'
  #   ENV['LEVEL_ONE_1_LEVEL_TWO_2_LEVEL_THREE_1'] = '[1, 2, 3]'
  #
  #   EnvironmentFilter.execute(
  #     level_one_1: {
  #       level_two_1: 4,
  #       level_two_2: {
  #         level_three_1: [4, 5, 6] } } )
  #
  #   # => {
  #     'level_one_1' => {
  #       'level_two_1' => 1,
  #       'level_two_2' => {
  #         'level_three_1' => [1, 2, 3],
  #   }
  #
  #   ###
  #   # Can inject environment variables if said variables are prefixed
  #   #
  #   ENV['PREFIX_LEVEL_TWO_1'] = 'env value 1'
  #   ENV['PREFIX_LEVEL_TWO_2'] = 'env value 2'
  #
  #   EnvironmentFilter.execute({
  #                               level_two_1: 'value 1',
  #                               level_two_2: 'value 2'
  #                             },
  #                             ['prefix'])
  #
  #   # => {
  #     'level_two_1' => 'env value 1',
  #     'level_two_2' => 'env value 2',
  #   }
  #
  #
  def self.execute(**args)
    new(**args).__send__(:execute)
  end


  def initialize(data:, secure_key_prefix:, **_args)
    self.data             = data
    self.secure_key_token = /\A#{Regexp.escape(secure_key_prefix)}/
  end

  protected

  def execute(settings = data, parent_keys = [])
    with_environment(
      settings,
      parent_keys,
      lambda do |key, value, environment_keys|
        { key => execute(value, environment_keys) }
      end,
      lambda do |key, value, environment_key|
        {
          key => convert_environment_value(environment_key,
                                           ENV.fetch(environment_key, nil),
                                           value),
        }
      end,
    )
  end

  private

  def with_environment(settings, parent_keys, hash_block, value_block)
    environment_hash = {}

    settings.each_pair do |key, value|
      environment_key  = key.to_s.gsub(secure_key_token, '')
      environment_keys = parent_keys.dup.push(environment_key)

      if value.respond_to? :each_pair
        environment_hash.merge!(hash_block.call(key, value, environment_keys))
      else
        environment_key = environment_keys.join('_').upcase

        environment_hash.merge!(value_block.call(key, value, environment_key))
      end
    end

    environment_hash
  end

  def convert_environment_value(environment_key, environment_value, settings_value) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize
    return settings_value unless environment_value
    return                if %w{___nil___ ___null___}.include?(environment_value)

    case settings_value.class.name
    when 'TrueClass', 'FalseClass'
      case environment_value.downcase
      when 'false', 'f', 'no', 'off', '0'
        false
      when 'true', 't', 'yes', 'on', '1'
        true
      else
        fail ArgumentError, "Invalid value for Boolean: #{environment_value}"
      end
    when 'Float'
      Float(environment_value)
    when 'Time'
      Time.iso8601(environment_value)
    when 'Array'
      YAML.safe_load(environment_value).tap do |parsed_value|
        unless parsed_value.is_a?(Array)
          fail ArgumentError, "Invalid value for Array: #{environment_value}"
        end
      end
    when 'Fixnum', 'Integer'
      Integer(environment_value)
    else
      environment_value
    end
  rescue ArgumentError
    raise Chamber::Errors::EnvironmentConversion, <<~HEREDOC
      We attempted to convert '#{environment_key}' from '#{environment_value}' to a '#{settings_value.class.name}'.

      Unfortunately, this did not go as planned.  Please either verify that your value is convertable
      or change the original YAML value to be something more generic (like a String).

      For more information, see https://github.com/thekompanee/chamber/wiki/Environment-Variable-Coercions
    HEREDOC
  end
end
end
end
