# frozen_string_literal: true

require 'chamber/refinements/deep_dup'

module  Chamber
module  Filters
class   SecureFilter
  using ::Chamber::Refinements::DeepDup

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
    settings = {}

    raw_data.each_pair do |key, value|
      secure_value  = if value.respond_to? :each_pair
                        execute(value)
                      elsif key.respond_to? :match
                        value if key.match(secure_key_token)
                      end

      settings[key] = secure_value unless secure_value.nil?
    end

    settings
  end
end
end
end
