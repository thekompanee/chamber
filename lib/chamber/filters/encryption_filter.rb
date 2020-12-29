# frozen_string_literal: true

require 'openssl'
require 'hashie/mash'
require 'yaml'
require 'chamber/encryption_methods/public_key'
require 'chamber/encryption_methods/ssl'
require 'chamber/encryption_methods/none'

module    Chamber
module    Filters
class     EncryptionFilter
  BASE64_STRING_PATTERN     = %r{\A[A-Za-z0-9+/]{342}==\z}.freeze
  BASE64_SUBSTRING_PATTERN  = %r{[A-Za-z0-9+/#]*={0,2}}.freeze
  LARGE_DATA_STRING_PATTERN = /
                                \A
                                (#{BASE64_SUBSTRING_PATTERN})
                                \#
                                (#{BASE64_SUBSTRING_PATTERN})
                                \#
                                (#{BASE64_SUBSTRING_PATTERN})
                                \z
                              /x.freeze

  attr_accessor :data,
                :secure_key_token
  attr_reader   :encryption_keys

  def initialize(data:, secure_key_prefix:, encryption_keys: {}, **_args)
    self.encryption_keys  = encryption_keys || {}
    self.data             = data.dup
    self.secure_key_token = /\A#{Regexp.escape(secure_key_prefix)}/
  end

  def self.execute(**args)
    new(**args).__send__(:execute)
  end

  protected

  def execute(raw_data = data, namespace = nil)
    raw_data.each_with_object(Hashie::Mash.new) do |(key, value), settings|
      settings[key] = if value.respond_to? :each_pair
                        execute(value, namespace || key)
                      elsif key.match(secure_key_token)
                        encrypt(namespace, key, value)
                      else
                        value
                      end
    end
  end

  def encryption_keys=(other)
    @encryption_keys = other.each_with_object({}) do |(namespace, keyish), memo|
      memo[namespace] = if keyish.is_a?(OpenSSL::PKey::RSA)
                          keyish
                        elsif ::File.readable?(::File.expand_path(keyish))
                          file_contents = ::File.read(::File.expand_path(keyish))
                          OpenSSL::PKey::RSA.new(file_contents)
                        else
                          OpenSSL::PKey::RSA.new(keyish)
                        end
    end
  end

  private

  def encrypt(namespace, key, value)
    method         = encryption_method(value)
    encryption_key = encryption_keys[namespace] || encryption_keys[:__default]

    return value unless encryption_key

    method.encrypt(key, value, encryption_key)
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
