require 'chamber/commands/base'
require 'chamber/commands/travis'
require 'chamber/commands/securable'

module  Chamber
module  Commands
module  Travis
class   Secure < Chamber::Commands::Base
  include Chamber::Commands::Travis
  include Chamber::Commands::Securable

  def call
    securable_environment_variables.each do |key, value|
      if dry_run
        shell.say_status 'encrypt', key, :blue
      else
        command = first_environment_variable?(key) ? '--override' : '--append'

        shell.say_status 'encrypt', key, :green
        travis_encrypt("#{command} #{key}=#{value}")
      end
    end
  end

  protected

  def first_environment_variable?(key)
    @first_environment_key ||= securable_environment_variables.first[0]

    @first_environment_key == key
  end
end
end
end
end
