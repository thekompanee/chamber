# frozen_string_literal: true

require 'yaml'
require 'hashie/mash'

module  Chamber
module  Filters
class   EnvironmentFilter
  ###
  # Internal: Allows the existing environment to be injected into the passed in
  # hash.  The hash that is passed in is *not* modified, instead a new hash is
  # returned.
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
  def self.execute(options = {})
    new(options).__send__(:execute)
  end

  attr_accessor :data,
                :secure_key_token

  def initialize(options = {})
    self.data             = options.fetch(:data)
    self.secure_key_token = /\A#{Regexp.escape(options.fetch(:secure_key_prefix))}/
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
        { key => convert_environment_value(ENV[environment_key], value) }
      end,
    )
  end

  private

  def with_environment(settings, parent_keys, hash_block, value_block)
    environment_hash = Hashie::Mash.new

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

  # rubocop:disable Metrics/CyclomaticComplexity
  def convert_environment_value(environment_value, settings_value)
    return settings_value unless environment_value

    case settings_value.class.name
    when 'TrueClass', 'FalseClass'
      case environment_value.downcase
      when 'false', 'f', 'no'
        false
      when 'true', 't', 'yes'
        true
      else
        fail ArgumentError, "Invalid value for Boolean: #{environment_value}"
      end
    when 'Float'
      Float(environment_value)
    when 'Array'
      YAML.safe_load(environment_value).tap do |parsed_value|
        unless parsed_value.is_a?(Array)
          fail ArgumentError, "Invalid value for Array: #{environment_value}"
        end
      end
    when 'Integer'
      Integer(environment_value)
    else
      environment_value
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
end
end
end
