# frozen_string_literal: true
require 'chamber/hashie_mash'
require 'chamber/filters/secure_filter'

module  Chamber
module  Filters
class   InsecureFilter < SecureFilter
  BASE64_STRING_PATTERN     = %r{\A[A-Za-z0-9\+\/]{342}==\z}
  LARGE_DATA_STRING_PATTERN = %r{\A([A-Za-z0-9\+\/#]*\={0,2})#([A-Za-z0-9\+\/#]*\={0,2})#([A-Za-z0-9\+\/#]*\={0,2})\z} # rubocop:disable Metrics/LineLength

  protected

  def execute(raw_data = data)
    securable_settings = super
    settings           = HashieMash.new

    securable_settings.each_pair do |key, value|
      value = if value.respond_to? :each_pair
                execute(value)
              elsif value.respond_to? :match
                value unless value.match(BASE64_STRING_PATTERN) ||
                             value.match(LARGE_DATA_STRING_PATTERN)
              end

      settings[key] = value unless value.nil?
    end

    settings
  end
end
end
end
