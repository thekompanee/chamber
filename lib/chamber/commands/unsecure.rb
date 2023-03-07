# frozen_string_literal: true

require 'chamber/commands/base'
require 'chamber/commands/securable'

module  Chamber
module  Commands
class   Unsecure < Chamber::Commands::Base
  include Chamber::Commands::Securable

  def initialize(**args)
    super(**args.merge(namespaces: ['*']))
  end

  def call
    disable_warnings do
      current_settings.secure.to_environment.each_key do |key|
        color = dry_run ? :blue : :green

        shell.say_status 'decrypt', key, color
      end
    end

    chamber.unsecure unless dry_run
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
