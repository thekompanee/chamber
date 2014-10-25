require 'chamber/commands/base'
require 'chamber/commands/securable'
require 'chamber/commands/heroku'

module  Chamber
module  Commands
module  Heroku
class   Push < Chamber::Commands::Base
  include Chamber::Commands::Securable
  include Chamber::Commands::Heroku

  def call
    securable_environment_variables.each do |key, value|
      if dry_run
        shell.say_status 'push', key, :blue
      else
        shell.say_status 'push', key, :green
        heroku("config:set #{key}=#{value}")
      end
    end
  end
end
end
end
end
