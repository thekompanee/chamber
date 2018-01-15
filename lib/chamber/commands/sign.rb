# frozen_string_literal: true

require 'chamber/commands/base'

module  Chamber
module  Commands
class   Sign < Chamber::Commands::Base
  def initialize(options = {})
    super(options.merge(namespaces: ['*']))
  end

  def call
    chamber.sign
  end
end
end
end
