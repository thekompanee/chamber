require 'yaml'
require 'erb'

require 'chamber/version'

module Chamber
  class ChamberInvalidOptionError < ArgumentError; end

  def source(filename, options={})
    assert_valid_keys(options)

    hash = hash_from_source(filename, options[:namespace])
    if options[:override_from_environment]
      override_from_environment!(hash)
    end

    instance.deep_merge!(hash)
  end

  def instance
    @instance ||= Hashie::Mash.new
  end

private
  def assert_valid_keys(options)
    unknown_keys = options.keys - [:namespace, :override_from_environment]

    raise(ChamberInvalidOptionError, options) unless unknown_keys.empty?
  end

  def override_from_environment!(hash)
    hash.each_pair do |key, value|
      next unless value.is_a?(Hash)

      if !value.environment.blank?
        hash[key] = ENV[value.environment]
      else
        override_from_environment!(value)
      end
    end
  end

  def hash_from_source(filename, namespace)
    contents = open(filename).read
    hash = YAML.load(ERB.new(contents).result).to_hash
    hash = Hashie::Mash.new(hash)

    namespace ? hash[namespace] : hash
  end
end
