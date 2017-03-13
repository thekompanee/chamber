# frozen_string_literal: true
require 'chamber/environmentable'

module  Chamber
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
  #   # Replaces arrays
  #   # Maintains type of integers and arrays
  #   #
  #   ENV['LEVEL_ONE_1_LEVEL_TWO_1']               = 'env value 1'
  #   ENV['LEVEL_ONE_1_LEVEL_TWO_2_LEVEL_THREE_1'] = 'env value 2'
  #   ENV['LEVEL_ONE_1_INTEGER']                   = '2'
  #   ENV['LEVEL_ONE_1_FLOAT']                     = '3.14'
  #   ENV['LEVEL_ONE_1_ARRAY_0']                   = 'env value 3'
  #   ENV['LEVEL_ONE_1_ARRAY_1']                   = 'env value 4'
  #
  #   EnvironmentFilter.execute(
  #     level_one_1: {
  #       level_two_1: 'value 1',
  #       level_two_2: {
  #         level_three_1: 'value 2' },
  #       integer: 1,
  #       float: 2.17,
  #       array: [ 'value 3', 'value 4' ] } )
  #
  #   # => {
  #     'level_one_1' => {
  #       'level_two_1' => 'env value 1',
  #       'level_two_2' => {
  #         'level_three_1' => 'env value 2',
  #       'integer' => 2,
  #       'float' => 3.14,
  #       'array' => [ 'env value 3', 'env value 4' ]
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

  protected

  attr_accessor :data

  def execute(settings = data, parent_keys = [])
    with_environment(settings, parent_keys,
                     lambda do |key, value, environment_keys|
                       { key => execute(value, environment_keys) }
                     end,
                     lambda do |key, value, environment_key|
                       if value.is_a? Array
                         if ENV[environment_key] == '0'
                           { key => [] }
                         else
                           env_values = ENV.keys
                                        .select{ |e|
                                          e =~ /^#{environment_key}_\d+$/
                                        }.sort.map{ |e|
                                          match_type(ENV[e], value[0])
                                        }
                           if env_values.length > 0
                             { key => env_values }
                           else
                             { key => value }
                           end
                         end
                       else
                         { key => ENV[environment_key].nil? ? value : match_type(ENV[environment_key], value) }
                       end
                     end)
  end

  def match_type(value, template)
    if template.is_a? Integer
      value.to_i
    elsif template.is_a? Float
      value.to_f
    else
      value
    end
  end
end
end
end
