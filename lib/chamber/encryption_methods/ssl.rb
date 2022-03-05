# frozen_string_literal: true

require 'base64'

module  Chamber
module  EncryptionMethods
class   Ssl
  BASE64_STRING_PATTERN     = %r{[A-Za-z0-9+/#]*={0,2}}.freeze
  LARGE_DATA_STRING_PATTERN = /
                                \A
                                (#{BASE64_STRING_PATTERN})
                                \#
                                (#{BASE64_STRING_PATTERN})
                                \#
                                (#{BASE64_STRING_PATTERN})
                                \z
                              /x.freeze

  def self.encrypt(_key, value, encryption_keys) # rubocop:disable Metrics/AbcSize
    value         = YAML.dump(value)
    cipher        = OpenSSL::Cipher.new('AES-128-CBC')
    cipher.encrypt
    symmetric_key = cipher.random_key
    iv            = cipher.random_iv

    # encrypt all data with this key and iv
    encrypted_data = cipher.update(value) + cipher.final

    # encrypt the key with the public key
    encrypted_key = encryption_keys.public_encrypt(symmetric_key)

    # assemble the resulting Base64 encoded data, the key
    Base64.strict_encode64(encrypted_key) + '#' +
    Base64.strict_encode64(iv) + '#' +
    Base64.strict_encode64(encrypted_data)
  end

  def self.decrypt(key, value, decryption_keys) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength
    if decryption_keys.nil?
      value
    else
      key, iv, decoded_string = value
                                  .match(LARGE_DATA_STRING_PATTERN)
                                  .captures
                                  .map do |part|
        Base64.strict_decode64(part)
      end
      key                     = decryption_keys.private_decrypt(key)

      cipher_dec = OpenSSL::Cipher.new('AES-128-CBC')

      cipher_dec.decrypt

      cipher_dec.key = key
      cipher_dec.iv  = iv

      begin
        unencrypted_value = cipher_dec.update(decoded_string) + cipher_dec.final
      rescue OpenSSL::Cipher::CipherError
        raise Chamber::Errors::DecryptionFailure,
              'A decryption error occurred. It was probably due to invalid key data.'
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
