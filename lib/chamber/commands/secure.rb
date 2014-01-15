require 'chamber/commands/base'

module  Chamber
module  Commands
class   Secure < Chamber::Commands::Base

  def initialize(options = {})
    super(options.merge(namespaces: ['*']))
  end

  def call
    chamber.secure
  end
end
end
end
