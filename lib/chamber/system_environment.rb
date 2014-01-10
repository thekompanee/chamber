require 'chamber/environmentable'

###
# Internal: Gives access to the existing environment for importing/exporting
# values.
#
module  Chamber
module  SystemEnvironment
  extend Environmentable

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
end
end
