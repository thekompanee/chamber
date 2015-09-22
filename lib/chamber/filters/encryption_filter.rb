require 'openssl'
require 'base64'
require 'hashie/mash'
require 'yaml'

module    Chamber
module    Filters
class     EncryptionFilter
  SECURE_KEY_TOKEN      = /\A_secure_/
  BASE64_STRING_PATTERN = %r{\A[A-Za-z0-9\+\/]{342}==\z}
  LARGEDATA_STRING_PATTERN  = %r{\A([A-Za-z0-9\+\/#]*\={0,2})#([A-Za-z0-9\+\/#]*\={0,2})#([A-Za-z0-9\+\/#]*\={0,2})\z}

  def initialize(options = {})
    self.encryption_key = options.fetch(:encryption_key, nil)
    self.data           = options.fetch(:data).dup
  end

  def self.execute(options = {})
    new(options).send(:execute)
  end

  protected

  attr_accessor :data
  attr_reader   :encryption_key

  def execute(raw_data = data)
    settings = Hashie::Mash.new

    raw_data.each_pair do |key, value|
      if value.respond_to? :each_pair
        value = execute(value)
      elsif key.match(SECURE_KEY_TOKEN)
        unless value.respond_to?(:match) && value.match(BASE64_STRING_PATTERN)
          serialized_value = YAML.dump(value)
          if serialized_value.length > 128 # PKI can only be used at smaller data like symmetric keys
            #encrypted_string = encryption_certificate(encryption_key).public_encrypt(serialized_value)
            cipher = OpenSSL::Cipher::Cipher.new("AES-128-CBC")
            cipher.encrypt
            symmetric_key = cipher.random_key
            iv = cipher.random_iv

            # encrypt all data with this key and iv
            encrypted_data = cipher.update(serialized_value) + cipher.final

            # encrypt the key with the public key
            encrypted_key = encryption_key.public_encrypt(symmetric_key)

            # assemble the resulting Base64 encoded data, the key
            value = Base64.strict_encode64(encrypted_key) + '#' + Base64.strict_encode64(iv) + '#' + Base64.strict_encode64(encrypted_data)

          else
            encrypted_string = encryption_key.public_encrypt(serialized_value)
            value =  Base64.strict_encode64(encrypted_string)
          end
        end
      end

      settings[key] = value
    end

    settings
  end

  def encryption_key=(keyish)
    return @encryption_key = nil if keyish.nil?

    key_content     = if ::File.readable?(::File.expand_path(keyish))
                        ::File.read(::File.expand_path(keyish))
                      else
                        keyish
                      end

    @encryption_key = OpenSSL::PKey::RSA.new(key_content)
  end
end
end
end
