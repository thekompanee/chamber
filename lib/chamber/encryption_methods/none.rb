module  Chamber
module  EncryptionMethods
class   None
  def self.encrypt(key, value, encryption_key)
    value
  end

  def self.decrypt(key, value, decryption_key)
    warn "WARNING: It appears that you would like to keep your information for #{key} " \
         "secure, however the value for that setting does not appear to be encrypted. " \
         "Make sure you run 'chamber secure' before committing."

    value
  end
end
end
end
