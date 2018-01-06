# frozen_string_literal: true

require 'thor'
require 'chamber/rubinius_fix'
require 'chamber/binary/travis'
require 'chamber/binary/heroku'
require 'chamber/commands/show'
require 'chamber/commands/files'
require 'chamber/commands/secure'
require 'chamber/commands/compare'
require 'chamber/commands/initialize'

module  Chamber
module  Binary
class   Runner < Thor
  include Thor::Actions

  source_root ::File.expand_path('../../../../templates', __FILE__)

  class_option  :rootpath,
                type:    :string,
                aliases: '-r',
                default: ENV['PWD'],
                desc:    'The root filepath of the application'

  class_option  :basepath,
                type:    :string,
                aliases: '-b',
                desc:    'The base filepath where Chamber will look for the ' \
                         'conventional settings files'

  class_option  :files,
                type:    :array,
                aliases: '-f',
                desc:    'The set of file globs that Chamber will use for processing'

  class_option  :namespaces,
                type:    :array,
                aliases: '-n',
                default: [],
                desc:    'The set of namespaces that Chamber will use for processing'

  class_option  :preset,
                type:    :string,
                aliases: '-p',
                enum:    %w{rails},
                desc:    'Used to quickly assign a given scenario to the chamber ' \
                         'command (eg Rails apps)'

  class_option  :decryption_keys,
                type: :array,
                desc: 'The path to or contents of the private key (or keys) associated ' \
                      'with the project (typically .chamber.pem)'

  class_option  :encryption_keys,
                type: :array,
                desc: 'The path to or contents of the public key (or keys) associated ' \
                      'with the project (typically .chamber.pub.pem)'

  desc 'travis SUBCOMMAND ...ARGS',   'For manipulating Travis CI environment variables'
  subcommand 'travis', Chamber::Binary::Travis

  desc 'heroku SUBCOMMAND ...ARGS',   'For manipulating Heroku environment variables'
  subcommand 'heroku', Chamber::Binary::Heroku

  desc 'show', 'Displays the list of settings and their values'

  method_option :as_env,
                type:    :boolean,
                aliases: '-e',
                desc:    'Whether the displayed settings should be environment ' \
                         'variable compatible'

  desc 'only_sensitive', 'Only show secured/securable settings'

  method_option :only_sensitive,
                type:    :boolean,
                aliases: '-s',
                desc:    'Only displays the settings that are/should be secured. ' \
                         'Useful for debugging.'

  def show
    puts Commands::Show.call(options.merge(shell: self))
  end

  desc 'files', 'Lists the settings files which are parsed with the given options'
  def files
    puts Commands::Files.call(options.merge(shell: self))
  end

  desc 'compare', 'Displays the difference between what is currently stored in the ' \
                  'Heroku application\'s config and what Chamber knows about locally'

  method_option :keys_only,
                type:    :boolean,
                default: true,
                desc:    'Whether or not to only compare the keys but not the values ' \
                         'of the two sets of settings'

  method_option :first,
                type: :array,
                desc: 'The list of namespaces which will be used as the source of ' \
                      'the comparison'

  method_option :second,
                type: :array,
                desc: 'The list of namespaces which will be used as the destination ' \
                      'of the comparison'

  def compare
    Commands::Compare.call(options.merge(shell: self))
  end

  desc 'secure', 'Secures any values which appear to need to be encrypted in any of ' \
                 'the settings files which match irrespective of namespaces'

  method_option :only_sensitive,
                type:    :boolean,
                default: true

  method_option :dry_run,
                type:    :boolean,
                aliases: '-d',
                desc:    'Does not actually encrypt anything, but instead displays ' \
                         'what values would be encrypted'

  def secure
    Commands::Secure.call(options.merge(shell: self))
  end

  desc 'init', 'Sets Chamber up matching best practices for secure configuration ' \
               'management'

  def init
    Commands::Initialize.call(options.merge(shell: self))
  end
end
end
end
