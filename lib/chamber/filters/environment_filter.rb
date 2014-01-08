require 'chamber/environmentable'

class   Chamber
module  Filters
class   EnvironmentFilter
  include Environmentable

  def initialize(options = {})
    self.data = options.fetch(:data)
  end

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
    self.new(options).send(:execute)
  end

  protected

  attr_accessor :data

  def execute(settings = data, parent_keys = [])
    with_environment(settings, parent_keys,
      ->(key, value, environment_keys) do
        { key => execute(value, environment_keys) }
      end,
      ->(key, value, environment_key) do
        { key => (ENV[environment_key] || value) }
      end)
  end
end
end
end
