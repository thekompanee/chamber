# frozen_string_literal: true

# `require 'pp'` is required.
# See https://github.com/thekompanee/chamber/issues/84
# rubocop:disable Lint/RedundantRequireStatement
require 'pp'
# rubocop:enable Lint/RedundantRequireStatement

require 'chamber/commands/base'

module  Chamber
module  Commands
class   Show < Chamber::Commands::Base
  attr_accessor :as_env,
                :only_sensitive

  def initialize(as_env: nil, only_sensitive: nil, **args)
    super(**args)

    self.as_env         = as_env
    self.only_sensitive = only_sensitive
  end

  def call
    if as_env
      settings.to_s(pair_separator: "\n")
    else
      PP
        .pp(settings.to_hash, StringIO.new, 60)
        .string
        .chomp
    end
  end

  protected

  def settings
    @settings ||= if only_sensitive
                    chamber.settings.securable
                  else
                    chamber.settings
                  end
  end
end
end
end
