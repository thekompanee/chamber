# frozen_string_literal: true

require 'base64'

require 'chamber/errors/disallowed_class'

module  Chamber
module  EncryptionMethods
class   PublicKey
  def self.encrypt(_key, value, encryption_key)
    value            = YAML.dump(value)
    encrypted_string = encryption_key.public_encrypt(value)

    Base64.strict_encode64(encrypted_string)
  end

  def self.decrypt(_key, value, decryption_key)
    if decryption_key.nil?
      value
    else
      decoded_string    = Base64.strict_decode64(value)
      unencrypted_value = decryption_key.private_decrypt(decoded_string)

      begin
        YAML.safe_load(unencrypted_value,
                       aliases:           true,
                       permitted_classes: [
                                            ::Date,
                                            ::Time,
                                            ::Regexp,
                                          ])
      rescue ::Psych::DisallowedClass => error
        raise ::Chamber::Errors::DisallowedClass, <<~HEREDOC
          #{error.message}

          You attempted to load a class instance via your Chamber settings that is not allowed.

          See https://github.com/thekompanee/chamber/wiki/Upgrading-To-Chamber-3.0#limiting-complex-classes for full details.
        HEREDOC
      rescue TypeError
        unencrypted_value
      end
    end
  end
end
end
end
