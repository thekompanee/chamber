require 'chamber/commands/base'

module  Chamber
module  Commands
class   Secure < Chamber::Commands::Base
  include Chamber::Commands::Securable

  def initialize(options = {})
    super(options.merge(namespaces: ['*']))
  end

  def call
    disable_warnings do
      insecure_environment_variables.each do |key, value|
        if dry_run
          shell.say_status 'encrypt', key, :blue
        else
          shell.say_status 'encrypt', key, :green
        end
      end
    end

    chamber.secure unless dry_run
  end

  private

  def disable_warnings
    $stderr = ::File.open('/dev/null', 'w')

    yield

    $stderr = STDERR
  end
end
end
end
