require 'pathname'
require 'openssl'
require 'chamber/configuration'
require 'chamber/commands/base'

module  Chamber
module  Commands
class   Initialize < Chamber::Commands::Base
  def initialize(options = {})
    super

    self.basepath = Chamber.configuration.basepath
  end

  def call
    shell.create_file private_key_filepath,    rsa_private_key.to_pem
    shell.create_file protected_key_filepath,  rsa_protected_key
    shell.create_file public_key_filepath,     rsa_public_key.to_pem

    `chmod 600 #{private_key_filepath}`
    `chmod 600 #{protected_key_filepath}`
    `chmod 644 #{public_key_filepath}`

    unless ::File.read(gitignore_filepath).match(/^.chamber.pem$/)
      shell.append_to_file gitignore_filepath, private_key_filepath.basename.to_s
      shell.append_to_file gitignore_filepath, protected_key_filepath.basename.to_s
    end

    shell.copy_file settings_template_filepath, settings_filepath

    # rubocop:disable Metrics/LineLength
    shell.say ''
    shell.say 'The passphrase for your encrypted private key is:', :green
    shell.say ''
    shell.say rsa_key_passphrase, :green
    shell.say ''
    shell.say 'Store this securely somewhere.', :green
    shell.say ''
    shell.say 'You can send them the file located at:', :green
    shell.say ''
    shell.say protected_key_filepath, :green
    shell.say ''
    shell.say 'and not have to worry about sending it via a secure medium (such as', :green
    shell.say 'email), however do not send the passphrase along with it.  Give it to'
    shell.say 'your team members in person.', :green
    shell.say ''
    shell.say 'In order for them to decrypt it (for use with Chamber), they can run:'
    shell.say ''
    shell.say "$ cp /path/to/{#{protected_key_filepath.basename},#{private_key_filepath.basename}}", :green
    shell.say "$ ssh-keygen -p -f /path/to/#{private_key_filepath.basename}", :green
    shell.say ''
    shell.say 'Enter the passphrase when prompted and leave the new passphrase blank.', :green
    shell.say ''
    # rubocop:enable Metrics/LineLength
  end

  def self.call(options = {})
    new(options).call
  end

  protected

  attr_accessor :basepath

  def settings_template_filepath
    @settings_template_filepath ||= templates_path + 'settings.yml'
  end

  def templates_path
    @templates_path             ||= gem_path + 'templates'
  end

  def gem_path
    @gem_path                   ||= Pathname.new(
                                      ::File.expand_path('../../../..', __FILE__))
  end

  def settings_filepath
    @settings_filepath          ||= basepath + 'settings.yml'
  end

  def gitignore_filepath
    @gitignore_filepath         ||= rootpath + '.gitignore'
  end

  def protected_key_filepath
    @protected_key_filepath     ||= rootpath + '.chamber.pem.enc'
  end

  def private_key_filepath
    @private_key_filepath       ||= rootpath + '.chamber.pem'
  end

  def public_key_filepath
    @public_key_filepath        ||= rootpath + '.chamber.pub.pem'
  end

  def rsa_protected_key
    @rsa_protected_key          ||= begin
                                      cipher = OpenSSL::Cipher.new 'AES-128-CBC'
                                      key    = OpenSSL::PKey::RSA.new(2048)

                                      key.export cipher, rsa_key_passphrase
                                    end
  end

  def rsa_private_key
    @rsa_private_key            ||= OpenSSL::PKey::RSA.new(2048)
  end

  def rsa_public_key
    rsa_private_key.public_key
  end

  def rsa_key_passphrase
    @rsa_key_passphrase         ||= SecureRandom.uuid
  end
end
end
end
