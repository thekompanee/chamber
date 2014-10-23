require 'hashie/mash'

module  Chamber
module  Filters
class   SecureFilter
  SECURE_KEY_TOKEN = /\A_secure_/

  def initialize(options = {})
    self.data = Hashie::Mash.new(options.fetch(:data))
  end

  def self.execute(options = {})
    self.new(options).send(:execute)
  end

  protected

  attr_accessor :data

  def execute(raw_data = data)
    settings = Hashie::Mash.new

    raw_data.each_pair do |key, value|
      secure_value  = if value.respond_to? :each_pair
                        execute(value)
                      elsif key.respond_to? :match
                        if key.match(SECURE_KEY_TOKEN)
                          value
                        end
                      end

      settings[key] = secure_value unless secure_value.nil?
    end

    settings
  end
end
end
end
