# frozen_string_literal: true
require 'openssl'
require 'base64'
require 'hashie/mash'
require 'yaml'
require 'chamber/errors/decryption_failure'

module  Chamber
module  Filters
class   DecryptionFilter
  SECURE_KEY_TOKEN      = /\A_secure_/
  BASE64_STRING_PATTERN = %r{\A[A-Za-z0-9\+/]{342}==\z}
  LARGEDATA_STRING_PATTERN  = %r{\A([A-Za-z0-9\+\/#]*\={0,2})#([A-Za-z0-9\+\/#]*\={0,2})#([A-Za-z0-9\+\/#]*\={0,2})\z}


  def initialize(options = {})
    self.decryption_key = options.fetch(:decryption_key, nil)
    self.data           = options.fetch(:data).dup
  end

  def self.execute(options = {})
    new(options).__send__(:execute)
  end

  protected

  attr_accessor :data
  attr_reader   :decryption_key

  def execute(raw_data = data)
    settings = Hashie::Mash.new

    raw_data.each_pair do |key, value|
      settings[key] = if value.respond_to? :each_pair
                        execute(value)
                      elsif key.match(SECURE_KEY_TOKEN) && value.respond_to?(:match)
                        read_or_decrypt(key, value)
                      else
                        value
                      end
    end

    settings
  end

  def decryption_key=(keyish)
    return @decryption_key = nil if keyish.nil?

    key_content     = if ::File.readable?(::File.expand_path(keyish))
                        ::File.read(::File.expand_path(keyish))
                      else
                        keyish
                      end

    @decryption_key = OpenSSL::PKey::RSA.new(key_content)
  end

  private

  def read_or_decrypt(key, value)
    if value.match(BASE64_STRING_PATTERN)
      decrypt(value)
    elsif value.match(LARGEDATA_STRING_PATTERN)
      decrypt_large_data(value)
    else
      warn "WARNING: It appears that you would like to keep your " \
           "information for #{key} secure, however the value for that " \
           "setting does not appear to be encrypted. Make sure you run " \
           "'chamber secure' before committing."

      value
    end
  end

  def decrypt(value)
    if decryption_key.nil?
      value
    else
      decoded_string    = Base64.strict_decode64(value)
      unencrypted_value = decryption_key.private_decrypt(decoded_string)

      begin
        _unserialized_value = YAML.load(unencrypted_value)
      rescue TypeError
        unencrypted_value
      end
    end
  end

  def decrypt_large_data(value)
    if decryption_key.nil?
      value
    else
      # the encoded data is in the formate <key>#<iv>#<encrypted data> with each part Base64 encoded
      key, iv, decoded_string = value.match(LARGEDATA_STRING_PATTERN).captures.map{|part| Base64.strict_decode64(part)}
      key = decryption_key.private_decrypt(key) # The key is decrypted with the private key

      cipher_dec = OpenSSL::Cipher::Cipher.new("AES-128-CBC")
      cipher_dec.decrypt
      cipher_dec.key = key
      cipher_dec.iv = iv

      begin
        unencrypted_value = cipher_dec.update(decoded_string) + cipher_dec.final
      rescue OpenSSL::Cipher::CipherError
        fail Chamber::Errors::DecryptionFailure, "A decryption error occurred, probably due to invalid key data."
      end

      begin
        _unserialized_value = YAML.load(unencrypted_value)
      rescue TypeError
        unencrypted_value
      end
    end
  end

end
end
end
