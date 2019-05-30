# frozen_string_literal: true

require 'chamber/commands/cloud/base'
require 'chamber/commands/comparable'
require 'chamber/commands/securable'

module  Chamber
module  Commands
module  Cloud
class   Compare < Chamber::Commands::Cloud::Base
  include Chamber::Commands::Securable
  include Chamber::Commands::Comparable

  protected

  def first_settings_data
    ::JSON.pretty_generate(securable_environment_variables)
  end

  def second_settings_data
    ::JSON.pretty_generate(adapter.environment_variables)
  end
end
end
end
end
