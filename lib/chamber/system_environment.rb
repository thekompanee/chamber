require 'hashie/mash'

###
# Internal: Gives access to the existing environment for importing/exporting
# values.
#
class   Chamber
module  SystemEnvironment

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
  #   SystemEnvironment.inject_into(
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
  #   SystemEnvironment.inject_into({
  #                                   level_two_1: 'value 1',
  #                                   level_two_2: 'value 2'
  #                                 },
  #                                 ['prefix'])
  #
  #   # => {
  #     'level_two_1' => 'env value 1',
  #     'level_two_2' => 'env value 2',
  #   }
  #
  #
  def self.inject_into(settings = {}, parent_keys = [])
    with_environment(settings, parent_keys,
      ->(key, value, environment_keys) do
        { key => inject_into(value, environment_keys) }
      end,
      ->(key, value, environment_key) do
        { key => convert_value(ENV[environment_key] || value) }
      end)
  end

  ###
  # Internal: Allows the environment variable-compatible variables to be
  # extracted from a passed in hash.
  #
  # Examples:
  #
  #   ###
  #   # Extracts the environment variables based on the hash keys
  #   #
  #   SystemEnvironment.extract_from(
  #     level_one_1: {
  #       level_two_1: 'value 1',
  #       level_two_2: {
  #         level_three_1: 'value 2' } } )
  #
  #   # => {
  #     'LEVEL_ONE_1_LEVEL_TWO_1'               => 'env value 1',
  #     'LEVEL_ONE_1_LEVEL_TWO_2_LEVEL_THREE_1' => 'env value 2',
  #   }
  #
  #   ###
  #   # Can extract environment variables if said variables are prefixed
  #   #
  #   SystemEnvironment.extract_from({
  #                                   level_two_1: 'value 1',
  #                                   level_two_2: 'value 2'
  #                                 },
  #                                 ['prefix'])
  #
  #   # => {
  #     'PREFIX_LEVEL_TWO_1' => 'value 1',
  #     'PREFIX_LEVEL_TWO_2' => 'value 2',
  #   }
  #
  def self.extract_from(settings, parent_keys = [])
    with_environment(settings, parent_keys,
      ->(key, value, environment_keys) do
        extract_from(value, environment_keys)
      end,
      ->(key, value, environment_key) do
        { environment_key => value.to_s }
      end)
  end

  private

  def self.with_environment(settings, parent_keys, hash_block, value_block)
    environment_hash = Hashie::Mash.new

    settings.each_pair do |key, value|
      environment_keys = parent_keys.dup.push(key)

      if value.respond_to? :each_pair
        environment_hash.merge!(hash_block.call(key, value, environment_keys))
      else
        environment_key = environment_keys.join('_').upcase

        environment_hash.merge!(value_block.call(key, value, environment_key))
      end
    end

    environment_hash
  end

  def self.convert_value(value)
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
