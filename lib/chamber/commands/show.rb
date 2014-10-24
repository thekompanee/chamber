require 'pp'
require 'chamber/commands/base'

module  Chamber
module  Commands
class   Show < Chamber::Commands::Base
  def initialize(options = {})
    super

    self.as_env      = options[:as_env]
    self.only_secure = options[:only_secure]
  end

  def call
    if as_env
      settings.to_s(pair_separator: "\n")
    else
      PP.
      pp(settings.to_hash, StringIO.new, 60).
      string.
      chomp
    end
  end

  protected

  attr_accessor :as_env,
                :only_secure

  def settings
    @settings ||= if only_secure
                    chamber.settings.securable
                  else
                    chamber.settings
                  end
  end
end
end
end
