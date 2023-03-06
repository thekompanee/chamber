# frozen_string_literal: true

require 'chamber/refinements/deep_dup'

module  Chamber
module  Filters
class   TranslateSecureKeysFilter
  using ::Chamber::Refinements::DeepDup

  attr_accessor :data,
                :secure_key_token

  def self.execute(**args)
    new(**args).__send__(:execute)
  end

  def initialize(data:, secure_key_prefix:, **_args)
    self.data             = data.deep_dup
    self.secure_key_token = /\A#{Regexp.escape(secure_key_prefix)}/
  end

  protected

  def execute(raw_data = data)
    settings = {}

    raw_data.each_pair do |key, value|
      value = execute(value) if value.respond_to? :each_pair
      key   = key.to_s
      key   = key.sub(secure_key_token, '') if key.match(secure_key_token)

      settings[key] = value
    end

    settings
  end
end
end
end
