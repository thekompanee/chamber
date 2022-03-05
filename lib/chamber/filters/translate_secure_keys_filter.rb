# frozen_string_literal: true

module  Chamber
module  Filters
class   TranslateSecureKeysFilter
  def self.execute(**args)
    new(**args).__send__(:execute)
  end

  attr_accessor :data,
                :secure_key_token

  def initialize(data:, secure_key_prefix:, **_args)
    self.data             = data.dup
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
