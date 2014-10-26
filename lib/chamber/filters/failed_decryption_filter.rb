require 'chamber/errors/decryption_failure'

module  Chamber
module  Filters
class   FailedDecryptionFilter
  SECURE_KEY_TOKEN      = /\A_secure_/
  BASE64_STRING_PATTERN = %r{\A[A-Za-z0-9\+/]{342}==\z}

  def initialize(options = {})
    self.data = options.fetch(:data).dup
  end

  def self.execute(options = {})
    new(options).send(:execute)
  end

  protected

  attr_accessor :data

  def execute(raw_data = data)
    settings = raw_data

    raw_data.each_pair do |key, value|
      if value.respond_to? :each_pair
        execute(value)
      elsif key.match(SECURE_KEY_TOKEN) &&
            value.respond_to?(:match)   &&
            value.match(BASE64_STRING_PATTERN)

        fail Chamber::Errors::DecryptionFailure,
             'Failed to decrypt values in your settings.'
      end
    end

    settings
  end
end
end
end
