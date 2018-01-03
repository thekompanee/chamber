# frozen_string_literal: true

require 'hashie/mash'

module  Chamber
module  Filters
class   SecureFilter
  def self.execute(options = {})
    new(options).__send__(:execute)
  end

  attr_accessor :data,
                :secure_key_token

  def initialize(options = {})
    self.data             = Hashie::Mash.new(options.fetch(:data))
    self.secure_key_token = /\A#{Regexp.escape(options.fetch(:secure_key_prefix))}/
  end

  protected

  def execute(raw_data = data)
    settings = Hashie::Mash.new

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
