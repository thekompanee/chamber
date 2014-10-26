require 'hashie/mash'

module  Chamber
module  Filters
class   TranslateSecureKeysFilter
  SECURE_KEY_TOKEN = /\A_secure_/

  def initialize(options = {})
    self.data = options.fetch(:data).dup
  end

  def self.execute(options = {})
    new(options).send(:execute)
  end

  protected

  attr_accessor :data

  def execute(raw_data = data)
    settings = Hashie::Mash.new

    raw_data.each_pair do |key, value|
      value = execute(value) if value.respond_to? :each_pair
      key   = key.to_s
      key   = key.sub(SECURE_KEY_TOKEN, '') if key.match(SECURE_KEY_TOKEN)

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
