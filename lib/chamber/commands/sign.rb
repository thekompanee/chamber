# frozen_string_literal: true

require 'chamber/commands/base'

module  Chamber
module  Commands
class   Sign < Chamber::Commands::Base
  def initialize(**args)
    super(**args.merge(namespaces: ['*']))
  end

  def call
    chamber.sign
  end
end
end
end
