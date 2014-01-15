require 'chamber/instance'
require 'chamber/commands/base'
require 'chamber/commands/comparable'

module  Chamber
module  Commands
class   Compare < Chamber::Commands::Base
  include Chamber::Commands::Comparable

  def initialize(options = {})
    super

    first_settings_options        = options.merge(namespaces: options[:first])
    self.first_settings_instance  = Chamber::Instance.new(first_settings_options)

    second_settings_options       = options.merge(namespaces: options[:second])
    self.second_settings_instance = Chamber::Instance.new(second_settings_options)
  end

  def self.call(options = {})
    self.new(options).call
  end

  protected

  attr_accessor :first_settings_instance,
                :second_settings_instance

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
