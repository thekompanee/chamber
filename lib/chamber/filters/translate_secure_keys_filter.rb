# frozen_string_literal: true

require 'hashie/mash'

module  Chamber
module  Filters
class   TranslateSecureKeysFilter
  SECURE_KEY_TOKEN = /\A_secure_/

  def self.execute(options = {})
    new(options).__send__(:execute)
  end

  attr_accessor :data

  def initialize(options = {})
    self.data = options.fetch(:data).dup
  end

  protected

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
end
end
end
