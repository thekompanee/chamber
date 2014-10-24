require 'chamber/commands/base'

module  Chamber
module  Commands
class   Files < Chamber::Commands::Base
  def call
    chamber.filenames
  end
end
end
end
