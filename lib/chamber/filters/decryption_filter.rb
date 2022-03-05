# frozen_string_literal: true

require 'openssl'
require 'base64'
require 'hashie/mash'
require 'yaml'
require 'chamber/encryption_methods/public_key'
require 'chamber/encryption_methods/ssl'
require 'chamber/encryption_methods/none'
require 'chamber/errors/decryption_failure'

module  Chamber
module  Filters
class   DecryptionFilter
  BASE64_STRING_PATTERN     = %r{\A[A-Za-z0-9+/]{342}==\z}.freeze
  LARGE_DATA_STRING_PATTERN = %r{
                                  \A                            # Beginning of String
                                  (
                                    [A-Za-z0-9+/#]*={0,2}       # Base64 Encoded Key
                                  )
                                  \#                            # Separator
                                  (
                                    [A-Za-z0-9+/#]*={0,2}       # Base64 Encoded IV
                                  )
                                  \#                            # Separator
                                  (
                                    [A-Za-z0-9+/#]*={0,2}       # Base64 Encoded Data
                                  )
                                  \z                            # End of String
                                }x.freeze

  attr_accessor :data,
                :secure_key_token
  attr_reader   :decryption_keys

  def initialize(data:, secure_key_prefix:, decryption_keys: {}, **_args)
    self.decryption_keys  = decryption_keys || {}
    self.data             = data.dup
    self.secure_key_token = /\A#{Regexp.escape(secure_key_prefix)}/
  end

  def self.execute(**args)
    new(**args).__send__(:execute)
  end

  protected

  def execute(raw_data = data)
    settings = Hashie::Mash.new

    raw_data.each_pair do |key, value|
      settings[key] = if value.respond_to? :each_pair
                        execute(value)
                      elsif key.match(secure_key_token)
                        decrypt(key, value)
                      else
                        value
                      end
    end

    settings
  end

  def decryption_keys=(other)
    @decryption_keys = other.each_value.map do |keyish|
      content = if ::File.readable?(::File.expand_path(keyish))
                  ::File.read(::File.expand_path(keyish))
                else
                  keyish
                end

      OpenSSL::PKey::RSA.new(content)
    end
  end

  private

  # rubocop:disable Style/RedundantBegin
  def decrypt(key, value)
    method = decryption_method(value)

    decryption_keys.each do |decryption_key|
      begin
        return method.decrypt(key, value, decryption_key)
      rescue OpenSSL::PKey::RSAError
        next
      end
    end

    value
  end
  # rubocop:enable Style/RedundantBegin

  def decryption_method(value)
    if value.is_a?(::String)
      if value.match(BASE64_STRING_PATTERN)
        EncryptionMethods::PublicKey
      elsif value.match(LARGE_DATA_STRING_PATTERN)
        EncryptionMethods::Ssl
      else
        EncryptionMethods::None
      end
    else
      EncryptionMethods::None
    end
  end
end
end
end
