# frozen_string_literal: true

require 'bundler'

module  Chamber
module  Commands
module  Heroku
  def initialize(options = {})
    super

    self.app = options[:app]
  end

  protected

  attr_accessor :app

  def configuration
    @configuration ||= heroku('config --shell').chomp
  end

  def heroku(command)
    Bundler.with_clean_env { `heroku #{command}#{app_option}` }
  end

  def app_option
    app ? " --app='#{app}'" : ''
  end
end
end
end
