# frozen_string_literal: true

require 'chamber/commands/base'
require 'chamber/commands/heroku'

module  Chamber
module  Commands
module  Heroku
class   Pull < Chamber::Commands::Base
  include Chamber::Commands::Heroku

  attr_accessor :target_file

  def initialize(options = {})
    super

    self.target_file = options[:into]
  end

  def call
    if target_file
      shell.create_file target_file, configuration
    else
      configuration
    end
  end
end
end
end
end
