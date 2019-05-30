# frozen_string_literal: true

require 'thor'
require 'chamber/commands/heroku/clear'
require 'chamber/commands/heroku/push'
require 'chamber/commands/heroku/pull'
require 'chamber/commands/heroku/compare'

module  Chamber
module  Binary
class   Heroku < Thor
  class_option :app,
               type:     :string,
               aliases:  '-a',
               required: true,
               desc:     'The name of the Heroku application whose config values will ' \
                         'be affected'

  desc 'clear', 'Removes all Heroku environment variables which match settings that ' \
                'Chamber knows about'

  method_option :dry_run,
                type:    :boolean,
                aliases: '-d',
                desc:    'Does not actually remove anything, but instead displays what ' \
                         'would change if cleared'

  def clear
    Commands::Heroku::Clear.call(options.merge(shell: self))
  end

  desc 'push', 'Sends settings to Heroku so that they may be used in the application ' \
               'once it is deployed'

  method_option :dry_run,
                type:    :boolean,
                aliases: '-d',
                desc:    'Does not actually push anything to Heroku, but instead ' \
                         'displays what would change if pushed'

  method_option :keys,
                type:    :boolean,
                aliases: '-k',
                desc:    'Pushes private Chamber keys to Heroku as environment ' \
                         'variables. Chamber will automatically detect it and ' \
                         'transparently decrypt your secure settings without any ' \
                         'further synchronization.'

  method_option :only_sensitive,
                type:    :boolean,
                aliases: '-o',
                default: true,
                desc:    'When enabled, only settings contained in files which have ' \
                         'been gitignored or settings which are marked as "_secure" ' \
                         'will be pushed'

  def push
    Commands::Heroku::Push.call(options.merge(shell: self))
  end

  desc 'pull', 'Retrieves the environment variables for the application and stores ' \
               'them in a temporary file'

  method_option :into,
                type: :string,
                desc: 'The file into which the Heroku config information should be ' \
                      'stored. This file WILL BE OVERRIDDEN.'

  def pull
    puts Commands::Heroku::Pull.call(options.merge(shell: self))
  end

  desc 'compare', 'Displays the difference between what is currently stored in the ' \
                  'Heroku application\'s config and what Chamber knows about locally'

  method_option :only_sensitive,
                type:    :boolean,
                aliases: '-o',
                default: true,
                desc:    'When enabled, the diff will only consider settings ' \
                         'contained in files which have been gitignored or settings ' \
                         'which are marked as "_secure"'

  def compare
    Commands::Heroku::Compare.call(options.merge(shell: self))
  end
end
end
end
