# frozen_string_literal: true

require 'thor'
require 'chamber/core_ext/hash'
require 'chamber/commands/cloud/clear'
require 'chamber/commands/cloud/push'
require 'chamber/commands/cloud/pull'
require 'chamber/commands/cloud/compare'

module  Chamber
module  Binary
class   CircleCi < Thor
  include Thor::Actions

  class_option :api_token,
               type:     :string,
               aliases:  '-t',
               required: true,
               desc:     'The API token to access your CircleCI project.'

  class_option :project,
               type:     :string,
               aliases:  '-p',
               required: true,
               desc:     'The project name in your VCS (eg Github).'

  class_option :username,
               type:     :string,
               aliases:  '-u',
               required: true,
               desc:     'The user/organization name in your VCS (eg Github).'

  class_option :vcs_type,
               type:    :string,
               aliases: '-v',
               default: 'github',
               desc:    'The type of VCS your project is using.',
               enum:    %w{github bitbucket}

  desc 'clear',
       'Removes all CircleCi environment variables which match settings that Chamber ' \
       'knows about'

  method_option :dry_run,
                type:    :boolean,
                aliases: '-d',
                desc:    'Does not actually remove anything, but instead displays what ' \
                         'would change if cleared'

  def clear
    Commands::Cloud::Clear.call(**options
                                    .transform_keys(&:to_sym)
                                    .merge(shell: self, adapter: 'circle_ci'))
  end

  desc 'push',
       'Sends settings to CircleCi so that they may be used in the application ' \
       'once it is deployed'

  method_option :dry_run,
                type:    :boolean,
                aliases: '-d',
                desc:    'Does not actually push anything to CircleCi, but instead ' \
                         'displays what would change if pushed'

  method_option :keys,
                type:    :boolean,
                aliases: '-k',
                desc:    'Pushes private Chamber keys to CircleCi as environment ' \
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
    Commands::Cloud::Push.call(**options
                                   .transform_keys(&:to_sym)
                                   .merge(shell: self, adapter: 'circle_ci'))
  end

  desc 'pull',
       'Retrieves the environment variables for the application and stores them in a ' \
       'temporary file'

  method_option :into,
                type: :string,
                desc: 'The file into which the CircleCi config information should be ' \
                      'stored. This file WILL BE OVERRIDDEN.'

  def pull
    Commands::Cloud::Pull.call(**options
                                   .transform_keys(&:to_sym)
                                   .merge(shell: self, adapter: 'circle_ci'))
  end

  desc 'compare',
       'Displays the difference between what is currently stored in the ' \
       'CircleCi application\'s config and what Chamber knows about locally'

  method_option :only_sensitive,
                type:    :boolean,
                aliases: '-o',
                default: true,
                desc:    'When enabled, the diff will only consider settings ' \
                         'contained in files which have been gitignored or settings ' \
                         'which are marked as "_secure"'

  def compare
    Commands::Cloud::Compare.call(**options
                                      .transform_keys(&:to_sym)
                                      .merge(shell: self, adapter: 'circle_ci'))
  end
end
end
end
