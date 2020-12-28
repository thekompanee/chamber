# frozen_string_literal: true

require 'hashie/mash'
require 'chamber/filters/secure_filter'

module  Chamber
module  Filters
class   InsecureFilter < SecureFilter
  BASE64_STRING_PATTERN     = %r{\A[A-Za-z0-9+/]{342}==\z}.freeze
  BASE64_SUBSTRING_PATTERN  = %r{[A-Za-z0-9+/#]*={0,2}}.freeze
  LARGE_DATA_STRING_PATTERN = /
                                \A
                                (#{BASE64_SUBSTRING_PATTERN})
                                \#
                                (#{BASE64_SUBSTRING_PATTERN})
                                \#
                                (#{BASE64_SUBSTRING_PATTERN})
                                \z
                              /x.freeze

  protected

  def execute(raw_data = data) # rubocop:disable Metrics/CyclomaticComplexity
    securable_settings = super
    settings           = Hashie::Mash.new

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
