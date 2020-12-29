# frozen_string_literal: true

require 'chamber/commands/base'

module  Chamber
module  Commands
class   Verify < Chamber::Commands::Base
  def initialize(**args)
    super(**args.merge(namespaces: ['*']))
  end

  def call
    verification_results = chamber.verify

    verification_results.each_pair do |filename, result|
      unless result
        shell.say("The signature for '#{filename}' failed verification.", :yellow)
      end
    end

    verification_results
  end
end
end
end
