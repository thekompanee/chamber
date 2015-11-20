require 'hashie/mash'

module  Chamber
module  Filters
class   SecureFilter
  def initialize(options = {})
    self.data = Hashie::Mash.new(options.fetch(:data))
  end

  def self.execute(options = {})
    new(options).send(:execute)
  end

  protected

  attr_accessor :data

  def execute(raw_data = data)
    settings = Hashie::Mash.new

    raw_data.each_pair do |key, value|
      secure_value  = if value.respond_to? :each_pair
                        execute(value)
                      elsif key.respond_to? :match
                        value if key.match(SECURE_KEY_TOKEN)
                      end

      settings[key] = secure_value unless secure_value.nil?
    end

    settings
  end
end
end
end
