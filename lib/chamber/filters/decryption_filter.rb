require 'openssl'
require 'base64'
require 'hashie/mash'
require 'chamber/errors/undecryptable_value_error'

module  Chamber
module  Filters
class   DecryptionFilter
  SECURE_KEY_TOKEN      = %r{\A_secure_}
  BASE64_STRING_PATTERN = %r{\A[A-Za-z0-9\+\/]{342}==\z}

  def initialize(options = {})
    self.decryption_key = options.fetch(:decryption_key, nil)
    self.data           = options.fetch(:data).dup
  end

  def self.execute(options = {})
    self.new(options).send(:execute)
  end

  protected

  attr_accessor :data
  attr_reader   :decryption_key

  def execute(raw_data = data)
    settings = Hashie::Mash.new

    raw_data.each_pair do |key, value|
      if value.respond_to? :each_pair
        value = execute(value)
      elsif value.respond_to? :match
        if key.match(SECURE_KEY_TOKEN)
          key   = key.to_s.sub(SECURE_KEY_TOKEN, '')
          value = if value.match(BASE64_STRING_PATTERN)
                    if decryption_key.nil?
                      value
                    else
                      decoded_string = Base64.strict_decode64(value)
                      decryption_key.private_decrypt(decoded_string)
                    end
                  else
                    warn "WARNING: It appears that you would like to keep your information for #{key} secure, however the value for that setting does not appear to be encrypted. Make sure you run 'chamber secure' before committing."

                    value
                  end
        else
          key = key.to_s
        end
      end

      settings[key] = value
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
end
end
end
