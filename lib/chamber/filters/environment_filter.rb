# frozen_string_literal: true

module  Chamber
module  Filters
class   EnvironmentFilter
  SECURE_KEY_TOKEN = /\A_secure_/

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

  attr_accessor :data

  def initialize(options = {})
    self.data = options.fetch(:data)
  end

  protected

  def execute(settings = data, parent_keys = [])
    with_environment(settings, parent_keys,
                     lambda do |key, value, environment_keys|
                       { key => execute(value, environment_keys) }
                     end,
                     lambda do |key, value, environment_key|
                       { key => (ENV[environment_key] || value) }
                     end)
  end

  private

  def with_environment(settings, parent_keys, hash_block, value_block)
    environment_hash = Hashie::Mash.new

    settings.each_pair do |key, value|
      environment_key  = key.to_s.gsub(SECURE_KEY_TOKEN, '')
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
end
end
end
