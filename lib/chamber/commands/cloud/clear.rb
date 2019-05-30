# frozen_string_literal: true

require 'chamber/commands/cloud/base'

module  Chamber
module  Commands
module  Cloud
class   Clear < Chamber::Commands::Cloud::Base
  def call
    chamber.to_environment.each_key do |key|
      next unless adapter.environment_variables.has_key?(key)

      if dry_run
        shell.say_status 'remove', key, :blue
      else
        shell.say_status 'remove', key, :green

        adapter.remove_environment_variable(key)
      end
    end
  end
end
end
end
end
