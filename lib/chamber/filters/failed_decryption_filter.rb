# frozen_string_literal: true

require 'chamber/errors/decryption_failure'
require 'chamber/refinements/deep_dup'

module  Chamber
module  Filters
class   FailedDecryptionFilter
  using ::Chamber::Refinements::DeepDup

  BASE64_STRING_PATTERN = %r{\A[A-Za-z0-9+/]{342}==\z}.freeze

  def self.execute(**args)
    new(**args).__send__(:execute)
  end

  attr_accessor :data,
                :secure_key_token

  def initialize(data:, secure_key_prefix:, **_args)
    self.data             = data.deep_dup
    self.secure_key_token = /\A#{Regexp.escape(secure_key_prefix)}/
  end

  protected

  def execute(raw_data = data)
    settings = raw_data

    raw_data.each_pair do |key, value|
      if value.respond_to? :each_pair
        execute(value)
      elsif key.match(secure_key_token) &&
            value.respond_to?(:match)   &&
            value.match(BASE64_STRING_PATTERN)

        fail Chamber::Errors::DecryptionFailure,
             "Failed to decrypt #{key} (with an encrypted value of '#{value}') " \
             "in your settings."
      end
    end

    settings
  end
end
end
end
