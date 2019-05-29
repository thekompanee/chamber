# frozen_string_literal: true

require 'pathname'
require 'securerandom'

module Chamber
class  KeyPair
  attr_accessor :key_file_path,
                :namespace,
                :passphrase

  def initialize(options = {})
    self.namespace     = options[:namespace]
    self.passphrase    = options.fetch(:passphrase, SecureRandom.uuid)
    self.key_file_path = Pathname.new(options.fetch(:key_file_path))
  end

  def encrypted_private_key_passphrase_filepath
    key_file_path + "#{encrypted_private_key_filename}.pass"
  end

  def encrypted_private_key_filepath
    key_file_path + encrypted_private_key_filename
  end

  def unencrypted_private_key_filepath
    key_file_path + unencrypted_private_key_filename
  end

  def public_key_filepath
    key_file_path + public_key_filename
  end

  def encrypted_private_key_pem
    encrypted_private_key
  end

  def unencrypted_private_key_pem
    unencrypted_private_key.to_pem
  end

  def public_key_pem
    public_key.to_pem
  end

  def encrypted_private_key_filename
    "#{base_key_filename}.enc"
  end

  def unencrypted_private_key_filename
    "#{base_key_filename}.pem"
  end

  def public_key_filename
    "#{base_key_filename}.pub.pem"
  end

  private

  def encrypted_private_key
    @encrypted_private_key ||= \
      unencrypted_private_key.export(encryption_cipher, passphrase)
  end

  def unencrypted_private_key
    @unencrypted_private_key ||= OpenSSL::PKey::RSA.new(2048)
  end

  def public_key
    @public_key ||= unencrypted_private_key.public_key
  end

  def encryption_cipher
    @encryption_cipher ||= OpenSSL::Cipher.new('AES-128-CBC')
  end

  def base_key_filename
    @base_key_filename ||= [
                             '.chamber',
                             namespace ? namespace.tr('-.', '') : nil,
                           ].
                             compact.
                             join('.')
  end
end
end
