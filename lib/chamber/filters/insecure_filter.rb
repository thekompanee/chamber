require 'hashie/mash'
require 'chamber/filters/secure_filter'

module  Chamber
module  Filters
class   InsecureFilter < SecureFilter
  BASE64 = %r{\A[A-Za-z0-9\+\/]{342}==\z}

  protected

  def execute(raw_data = data)
    securable_settings = super
    settings           = Hashie::Mash.new

    securable_settings.each_pair do |key, value|
      value = if value.respond_to? :each_pair
                execute(value)
              elsif value.respond_to? :match
                value unless value.match(BASE64)
              end

      settings[key] = value unless value.nil?
    end

    settings
  end
end
end
end
