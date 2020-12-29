# frozen_string_literal: true

require 'chamber/instance'
require 'chamber/commands/base'
require 'chamber/commands/comparable'

module  Chamber
module  Commands
class   Compare < Chamber::Commands::Base
  include Chamber::Commands::Comparable

  attr_accessor :first_settings_instance,
                :second_settings_instance

  def self.call(**args)
    new(**args).call
  end

  def initialize(first:, second:, **args)
    super(**args)

    self.first_settings_instance  = Chamber::Instance.new(args.merge(namespaces: first))
    self.second_settings_instance = Chamber::Instance.new(args.merge(namespaces: second))
  end

  protected

  def first_settings_data
    settings_data(first_settings_instance)
  end

  def second_settings_data
    settings_data(second_settings_instance)
  end

  def settings_data(instance)
    if keys_only
      instance.to_environment.keys.join("\n")
    else
      instance.to_s(pair_separator: "\n")
    end
  end
end
end
end
