# frozen_string_literal: true

require 'openssl'
require 'base64'
require 'hashie/mash'
require 'yaml'
require 'chamber/encryption_methods/public_key'
require 'chamber/encryption_methods/ssl'
require 'chamber/encryption_methods/none'
require 'chamber/errors/decryption_failure'

module  Chamber
module  Filters
class   DecryptionFilter
  BASE64_STRING_PATTERN     = %r{\A[A-Za-z0-9\+/]{342}==\z}
  LARGE_DATA_STRING_PATTERN = %r{\A([A-Za-z0-9\+\/#]*\={0,2})#([A-Za-z0-9\+\/#]*\={0,2})#([A-Za-z0-9\+\/#]*\={0,2})\z} # rubocop:disable Metrics/LineLength

  attr_accessor :data,
                :secure_key_token
  attr_reader   :decryption_key

  def initialize(options = {})
    self.decryption_key = options.fetch(:decryption_key, nil)
    self.data           = options.fetch(:data).dup
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
                        decryption_method(value).decrypt(key, value, decryption_key)
                      else
                        value
                      end
    end

    settings
  end

  def decryption_key=(keyish)
    if keyish.nil?
      @decryption_key = nil

      return
    end

    key_content     = if ::File.readable?(::File.expand_path(keyish))
                        ::File.read(::File.expand_path(keyish))
                      else
                        keyish
                      end

    @decryption_key = OpenSSL::PKey::RSA.new(key_content)
  end

  private

  def decryption_method(value)
    if value.respond_to?(:match)
      if value.match(BASE64_STRING_PATTERN)
        EncryptionMethods::PublicKey
      elsif value.match(LARGE_DATA_STRING_PATTERN)
        EncryptionMethods::Ssl
      else
        EncryptionMethods::None
      end
    else
      EncryptionMethods::None
    end
  end
end
end
end
