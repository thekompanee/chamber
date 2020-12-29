# frozen_string_literal: true

require 'json'
require 'chamber/commands/cloud/base'

module  Chamber
module  Commands
module  Cloud
class   Pull < Chamber::Commands::Cloud::Base
  attr_accessor :target_file

  def initialize(into:, **args)
    super

    self.target_file = into
  end

  def call
    if target_file
      shell.create_file(target_file,
                        ::JSON.pretty_generate(adapter.environment_variables))
    else
      adapter.environment_variables
    end
  end
end
end
end
end
