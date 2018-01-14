# frozen_string_literal: true

require 'pathname'
require 'fileutils'
require 'openssl'
require 'securerandom'
require 'chamber/configuration'
require 'chamber/key_pair'
require 'chamber/commands/base'

module  Chamber
module  Commands
class   Initialize < Chamber::Commands::Base
  def self.call(options = {})
    new(options).call
  end

  attr_accessor :basepath,
                :namespaces

  def initialize(options = {})
    super

    self.basepath   = Chamber.configuration.basepath
    self.namespaces = options.fetch(:namespaces, [])
  end

  # rubocop:disable Metrics/LineLength, Metrics/MethodLength, Metrics/AbcSize
  def call
    key_pairs = namespaces.map do |namespace|
      Chamber::KeyPair.new(namespace:     namespace,
                           key_file_path: rootpath)
    end
    key_pairs << Chamber::KeyPair.new(namespace:     nil,
                                      key_file_path: rootpath)

    key_pairs.each { |key_pair| generate_key_pair(key_pair) }

    append_to_gitignore

    shell.copy_file settings_template_filepath, settings_filepath, skip: true

    shell.say ''
    shell.say '********************************************************************************', :green
    shell.say '                                    Success!', :green
    shell.say '********************************************************************************', :green
    shell.say ''

    if namespaces.empty?
    end

    shell.say ''
    shell.say 'Store these securely somewhere and do not check them into the repository.'
    shell.say ''
    shell.say 'You can send your team members any of the file(s) located at:'
    shell.say ''

    key_pairs.each do |key_pair|
      shell.say '* '
      shell.say key_pair.encrypted_private_key_filepath, :yellow
    end

    shell.say ''
    shell.say 'and not have to worry about sending it via a secure medium, however do'
    shell.say 'not send the passphrase along with it.  Give it to your team members in'
    shell.say 'person.'

    shell.say 'The passphrases for your encrypted private key(s) are stored in the'
    shell.say 'following locations:'
    shell.say ''

    key_pairs.each do |key_pair|
      shell.say '* '
      shell.say key_pair.encrypted_private_key_passphrase_filepath, :yellow
    end

    shell.say ''
    shell.say 'In order for them to decrypt it (for use with Chamber), they can use something'
    shell.say 'like the following (swapping out the actual key filenames if necessary):'
    shell.say ''
    shell.say "$ cp #{key_pairs[0].encrypted_private_key_filepath} #{key_pairs[0].unencrypted_private_key_filepath}", :yellow
    shell.say "$ ssh-keygen -p -f #{key_pairs[0].unencrypted_private_key_filepath}", :yellow
    shell.say ''
    shell.say 'Enter the passphrase when prompted and leave the new passphrase blank.'
    shell.say ''
  end
  # rubocop:enable Metrics/LineLength, Metrics/MethodLength, Metrics/AbcSize

  protected

  def generate_key_pair(key_pair)
    shell.create_file key_pair.unencrypted_private_key_filepath,
                      key_pair.unencrypted_private_key_pem,
                      skip: true
    shell.create_file key_pair.encrypted_private_key_filepath,
                      key_pair.encrypted_private_key_pem,
                      skip: true
    shell.create_file key_pair.public_key_filepath,
                      key_pair.public_key_pem,
                      skip: true
    shell.create_file key_pair.encrypted_private_key_passphrase_filepath,
                      key_pair.passphrase,
                      skip: true

    `chmod 600 #{key_pair.unencrypted_private_key_filepath}`
    `chmod 600 #{key_pair.encrypted_private_key_filepath}`
    `chmod 600 #{key_pair.encrypted_private_key_passphrase_filepath}`
    `chmod 644 #{key_pair.public_key_filepath}`
  end

  # rubocop:disable Style/GuardClause
  def append_to_gitignore
    ::FileUtils.touch gitignore_filepath

    gitignore_contents = ::File.read(gitignore_filepath)

    unless gitignore_contents =~ /^\.chamber\*\.enc$/
      shell.append_to_file gitignore_filepath, ".chamber*.enc\n"
    end

    unless gitignore_contents =~ /^\.chamber\*\.pem$/
      shell.append_to_file gitignore_filepath, ".chamber*.pem\n"
    end

    unless gitignore_contents =~ /^\.chamber\*\.pem\.pass$/
      shell.append_to_file gitignore_filepath, ".chamber*.pem.pass\n"
    end
  end
  # rubocop:enable Style/GuardClause

  def settings_template_filepath
    @settings_template_filepath ||= templates_path + 'settings.yml'
  end

  def templates_path
    @templates_path             ||= gem_path + 'templates'
  end

  def gem_path
    @gem_path                   ||= Pathname.new(
                                      ::File.expand_path('../../../..', __FILE__),
                                    )
  end

  def settings_filepath
    @settings_filepath          ||= basepath + 'settings.yml'
  end

  def gitignore_filepath
    @gitignore_filepath         ||= rootpath + '.gitignore'
  end
end
end
end
