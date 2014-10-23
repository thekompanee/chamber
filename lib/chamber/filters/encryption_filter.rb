require 'openssl'
require 'base64'
require 'hashie/mash'

module    Chamber
module    Filters
class     EncryptionFilter
  SECURE_KEY_TOKEN      = /\A_secure_/
  BASE64_STRING_PATTERN = %r{\A[A-Za-z0-9\+\/]{342}==\z}

  def initialize(options = {})
    self.encryption_key = options.fetch(:encryption_key, nil)
    self.data           = options.fetch(:data).dup
  end

  def self.execute(options = {})
    self.new(options).send(:execute)
  end

  protected

  attr_accessor :data
  attr_reader   :encryption_key

  def execute(raw_data = data)
    settings = Hashie::Mash.new

    raw_data.each_pair do |key, value|
      if value.respond_to? :each_pair
        value = execute(value)
      elsif value.respond_to? :match
        if key.match(SECURE_KEY_TOKEN) && !value.match(BASE64_STRING_PATTERN)
          encrypted_string = encryption_key.public_encrypt(value)
          value            = Base64.strict_encode64(encrypted_string)
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
