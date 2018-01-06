# frozen_string_literal: true

require 'openssl'
require 'base64'
require 'hashie/mash'
require 'yaml'
require 'chamber/encryption_methods/public_key'
require 'chamber/encryption_methods/ssl'
require 'chamber/encryption_methods/none'

module    Chamber
module    Filters
class     EncryptionFilter
  BASE64_STRING_PATTERN     = %r{\A[A-Za-z0-9\+\/]{342}==\z}
  LARGE_DATA_STRING_PATTERN = %r{\A([A-Za-z0-9\+\/#]*\={0,2})#([A-Za-z0-9\+\/#]*\={0,2})#([A-Za-z0-9\+\/#]*\={0,2})\z} # rubocop:disable Metrics/LineLength

  attr_accessor :data,
                :secure_key_token
  attr_reader   :encryption_keys

  def initialize(options = {})
    self.encryption_keys  = options.fetch(:encryption_keys, {}) || {}
    self.data             = options.fetch(:data).dup
    self.secure_key_token = /\A#{Regexp.escape(options.fetch(:secure_key_prefix))}/
  end

  def self.execute(options = {})
    new(options).__send__(:execute)
  end

  protected

  def execute(raw_data = data)
    settings = Hashie::Mash.new

    raw_data.each_pair do |key, value|
      settings[key] = if value.respond_to? :each_pair
                        execute(value)
                      elsif key.match(secure_key_token)
                        encrypt(key, value)
                      else
                        value
                      end
    end

    settings
  end

  def encryption_keys=(other)
    @encryption_keys = other.each_value.map do |keyish|
      content = if ::File.readable?(::File.expand_path(keyish))
                  ::File.read(::File.expand_path(keyish))
                else
                  keyish
                end

      OpenSSL::PKey::RSA.new(content)
    end
  end

  private

  def encrypt(key, value)
    method = encryption_method(value)

    encryption_keys.each do |encryption_key|
      return method.encrypt(key, value, encryption_key)
    end

    value
  end

  def encryption_method(value)
    value_is_encrypted = value.respond_to?(:match) &&
                           (value.match(BASE64_STRING_PATTERN) ||
                            value.match(LARGE_DATA_STRING_PATTERN))

    if value_is_encrypted
      EncryptionMethods::None
    else
      serialized_value = YAML.dump(value)

      if serialized_value.length <= 128
        EncryptionMethods::PublicKey
      else
        EncryptionMethods::Ssl
      end
    end
  end
end
end
end
