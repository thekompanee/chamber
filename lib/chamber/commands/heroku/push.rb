# frozen_string_literal: true

require 'chamber/commands/base'
require 'chamber/commands/securable'
require 'chamber/commands/heroku'
require 'chamber/keys/decryption'

module  Chamber
module  Commands
module  Heroku
class   Push < Chamber::Commands::Base
  include Chamber::Commands::Securable
  include Chamber::Commands::Heroku

  attr_accessor :keys

  def initialize(options = {})
    super

    self.keys = options[:keys]
  end

  def call
    environment_variables = if keys
                              Keys::Decryption.
                                new(rootpath:   chamber.configuration.rootpath,
                                    namespaces: chamber.configuration.namespaces).
                                as_environment_variables
                            else
                            securable_environment_variables.
                              each_with_object({}) do |(key, value), memo|
                                memo[key] = value.shellescape
                              end
                            end

    environment_variables.each do |key, value|
      if dry_run
        shell.say_status 'push', key, :blue
      else
        shell.say_status 'push', key, :green
        heroku(%Q{config:set #{key}="#{value}"})
      end
    end
  end
end
end
end
end
