# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

module  Chamber
module  Adapters
module  Cloud
class   Heroku
  attr_accessor :app

  def initialize(options = {})
    self.app = options.fetch(:app)
  end

  def add_environment_variable(name, value)
    value = value.shellescape unless value.include?("\n")

    response = heroku(%Q{config:set #{name}="#{value}"})

    fail NameError, "The variable name '#{name}' is invalid" if response.include?('invalid')

    response
  end

  def environment_variables
    @environment_variables ||= ::JSON.parse(heroku('config --json'))
  end

  def remove_environment_variable(name)
    heroku("config:unset #{name}")
  end

  private

  def heroku(command)
    Bundler.with_clean_env { `heroku #{command}#{app_option} 2>&1` }
  end

  def app_option
    app ? " --app='#{app}'" : ''
  end
end
end
end
end
