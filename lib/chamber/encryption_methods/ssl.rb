module  Chamber
module  EncryptionMethods
class   Ssl
  LARGE_DATA_STRING_PATTERN = %r{\A([A-Za-z0-9\+\/#]*\={0,2})#([A-Za-z0-9\+\/#]*\={0,2})#([A-Za-z0-9\+\/#]*\={0,2})\z}

  def self.encrypt(key, value, encryption_key)
    value = YAML.dump(value)
    #encrypted_string = encryption_certificate(encryption_key).public_encrypt(value)
    cipher = OpenSSL::Cipher::Cipher.new("AES-128-CBC")
    cipher.encrypt
    symmetric_key = cipher.random_key
    iv = cipher.random_iv

    # encrypt all data with this key and iv
    encrypted_data = cipher.update(value) + cipher.final

    # encrypt the key with the public key
    encrypted_key = encryption_key.public_encrypt(symmetric_key)

    # assemble the resulting Base64 encoded data, the key
    Base64.strict_encode64(encrypted_key) + '#' + Base64.strict_encode64(iv) + '#' + Base64.strict_encode64(encrypted_data)
  end

  def self.decrypt(key, value, decryption_key)
    if decryption_key.nil?
      value
    else
      # the encoded data is in the formate <key>#<iv>#<encrypted data> with each part Base64 encoded
      key, iv, decoded_string = value.match(LARGE_DATA_STRING_PATTERN).captures.map{|part| Base64.strict_decode64(part)}
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
