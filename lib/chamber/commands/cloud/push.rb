# frozen_string_literal: true

require 'chamber/commands/cloud/base'
require 'chamber/commands/securable'
require 'chamber/keys/decryption'

module  Chamber
module  Commands
module  Cloud
class   Push < Chamber::Commands::Cloud::Base
  include Chamber::Commands::Securable

  attr_accessor :keys

  def initialize(options = {})
    super

    self.keys = options[:keys]
  end

  def call
    environment_variables = if keys
                              Keys::Decryption
                                .new(rootpath:   chamber.configuration.rootpath,
                                     namespaces: chamber.configuration.namespaces)
                                .as_environment_variables
                            else
                              securable_environment_variables
                            end

    environment_variables.each do |key, value|
      if dry_run
        shell.say_status 'push', key, :blue
      else
        shell.say_status 'push', key, :green

        adapter.add_environment_variable(key, value)
      end
    end
  end
end
end
end
end
