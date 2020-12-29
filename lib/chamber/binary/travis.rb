# frozen_string_literal: true

require 'thor'
require 'chamber/core_ext/hash'
require 'chamber/commands/travis/secure'

module  Chamber
module  Binary
class   Travis < Thor
  desc 'secure',
       'Uses your Travis CI public key to encrypt the settings you have ' \
       'chosen not to commit to the repo'

  method_option :dry_run,
                type:    :boolean,
                aliases: '-d',
                desc:    'Does not actually encrypt anything to .travis.yml, but ' \
                         'instead displays what values would be encrypted'

  method_option :only_sensitive,
                type:    :boolean,
                aliases: '-o',
                default: true,
                desc:    'Does not encrypt settings into .travis.yml unless they are ' \
                         'contained in files which have been gitignored or settings ' \
                         'which are marked as "_secure"'

  def secure
    Commands::Travis::Secure.call(**options.transform_keys(&:to_sym).merge(shell: self))
  end
end
end
end
