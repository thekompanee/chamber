# frozen_string_literal: true

require 'hashie/mash'

module  Chamber
module  Filters
class   TranslateSecureKeysFilter
  def self.execute(options = {})
    new(options).__send__(:execute)
  end

  attr_accessor :data,
                :secure_key_token

  def initialize(options = {})
    self.data = options.fetch(:data).dup
    self.secure_key_token = /\A#{Regexp.escape(options.fetch(:secure_key_prefix))}/
  end

  protected

  def execute(raw_data = data)
    settings = Hashie::Mash.new

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
