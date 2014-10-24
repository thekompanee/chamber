require 'pp'
require 'chamber/commands/base'

module  Chamber
module  Commands
class   Show < Chamber::Commands::Base
  def initialize(options = {})
    super

    self.as_env = options[:as_env]
  end

  def call
    as_env ? chamber.to_s(pair_separator: "\n") : PP.pp(chamber.to_hash, StringIO.new, 60).string.chomp
  end

  protected

  attr_accessor :as_env
end
end
end
