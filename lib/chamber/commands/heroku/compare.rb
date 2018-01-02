# frozen_string_literal: true

require 'chamber/commands/securable'
require 'chamber/commands/heroku'
require 'chamber/commands/comparable'

module  Chamber
module  Commands
module  Heroku
class   Compare < Chamber::Commands::Base
  include Chamber::Commands::Securable
  include Chamber::Commands::Heroku
  include Chamber::Commands::Comparable

  protected

  def first_settings_data
    if only_sensitive
      secured_settings.to_s(pair_separator:   "\n",
                            value_surrounder: '')
    else
      current_settings.to_s(pair_separator:   "\n",
                            value_surrounder: '')
    end
  end

  def second_settings_data
    configuration
  end
end
end
end
end
