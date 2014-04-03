require 'openssl'
require 'chamber/commands/base'

module  Chamber
module  Commands
class   Initialize < Chamber::Commands::Base

  def initialize(options = {})
    super

    self.basepath = Chamber.configuration.basepath
  end

  def call
    shell.create_file private_key_filepath, rsa_private_key.to_pem
    shell.create_file public_key_filepath,  rsa_public_key.to_pem

    `chmod 600 #{private_key_filepath}`
    `chmod 644 #{public_key_filepath}`

    unless ::File.read(gitignore_filepath).match(/^.chamber.pem$/)
      shell.append_to_file gitignore_filepath, private_key_filepath.basename.to_s
    end
     
    #Git pre-commit hook setup 
    if ::File.exists?(git_precommit_path)
      unless ::File.read(git_precommit_path).match(/^bundle exec chamber secure$/)
        shell.append_to_file git_precommit_path, "\nbundle exec chamber secure"
      end
    else
      shell.copy_file precommit_template_filepath, git_precommit_path
      `chmod +x #{git_precommit_path}`
    end  

    shell.copy_file settings_template_filepath, settings_filepath
  end

  def self.call(options = {})
    self.new(options).call
  end

  protected

  attr_accessor :basepath

  def settings_template_filepath
    @settings_template_filepath ||= templates_path + 'settings.yml'
  end

  def precommit_template_filepath
    @precommit_template_filepath ||= templates_path + 'pre-commit'
  end  
  
  def templates_path
    @templates_path             ||= Pathname.new(::File.expand_path('../../../../templates', __FILE__))
  end

  def settings_filepath
    @settings_filepath          ||= basepath + 'settings.yml'
  end

  def gitignore_filepath
    @gitignore_filepath         ||= rootpath + '.gitignore'
  end

  def private_key_filepath
    @private_key_filepath       ||= rootpath + '.chamber.pem'
  end

  def public_key_filepath
    @public_key_filepath        ||= rootpath + '.chamber.pub.pem'
  end

  def git_precommit_path
    @git_precommit_path          ||= rootpath + '.git/hooks/pre-commit'
  end  

  def rsa_key
    @rsa_key                    ||= OpenSSL::PKey::RSA.new(2048)
  end

  def rsa_private_key
    rsa_key
  end

  def rsa_public_key
    rsa_key.public_key
  end
end
end
end
