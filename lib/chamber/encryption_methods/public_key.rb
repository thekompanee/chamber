# frozen_string_literal: true

require 'base64'

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
        _unserialized_value = begin
                                YAML.safe_load(unencrypted_value,
                                               aliases:           true,
                                               permitted_classes: [
                                                                    ::Date,
                                                                    ::Time,
                                                                    ::Regexp,
                                                                  ])
                              rescue ::Psych::DisallowedClass => error
                                warn <<~HEREDOC
                                  WARNING: Recursive data structures (complex classes) being loaded from Chamber
                                  has been deprecated and will be removed in 3.0.

                                  See https://github.com/thekompanee/chamber/wiki/Upgrading-To-Chamber-3.0#limiting-complex-classes
                                  for full details.

                                  #{error.message}

                                  Called from: '#{caller.to_a[8]}'
                                HEREDOC

                                if YAML.respond_to?(:unsafe_load)
                                  YAML.unsafe_load(unencrypted_value)
                                else
                                  YAML.load(unencrypted_value)
                                end
                              end
      rescue TypeError
        unencrypted_value
      end
    end
  end
end
end
end
