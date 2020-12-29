# frozen_string_literal: true

require 'chamber/commands/base'
require 'chamber/commands/securable'

module  Chamber
module  Commands
class   Secure < Chamber::Commands::Base
  include Chamber::Commands::Securable

  def initialize(**args)
    super(**args.merge(namespaces: ['*']))
  end

  def call
    disable_warnings do
      insecure_environment_variables.each_key do |key|
        color = dry_run ? :blue : :green

        shell.say_status 'encrypt', key, color
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
