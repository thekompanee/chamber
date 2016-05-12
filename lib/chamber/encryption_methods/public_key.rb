module  Chamber
module  EncryptionMethods
class   PublicKey
  def self.decrypt(key, value, decryption_key)
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
