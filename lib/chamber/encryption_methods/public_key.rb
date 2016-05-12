module  Chamber
module  EncryptionMethods
class   PublicKey
  def self.encrypt(_key, value, encryption_key)
    value = YAML.dump(value)
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
        _unserialized_value = YAML.load(unencrypted_value)
      rescue TypeError
        unencrypted_value
      end
    end
  end
end
end
end
