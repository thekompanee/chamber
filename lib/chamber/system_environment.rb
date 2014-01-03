require 'hashie/mash'

class   Chamber
module  SystemEnvironment
  def self.inject_into(settings = {}, parent_keys = [])
    with_environment(settings, parent_keys,
      ->(key, value, environment_keys) do
        { key => inject_into(value, environment_keys) }
      end,
      ->(key, value, environment_key) do
        { key => convert_value(ENV[environment_key] || value) }
      end)
  end

  def self.extract_from(settings, parent_keys = [])
    with_environment(settings, parent_keys,
      ->(key, value, environment_keys) do
        extract_from(value, environment_keys)
      end,
      ->(key, value, environment_key) do
        { environment_key => value.to_s }
      end)
  end

  private

  def self.with_environment(settings, parent_keys, hash_block, value_block)
    environment_hash = Hashie::Mash.new

    settings.each_pair do |key, value|
      environment_keys = parent_keys.dup.push(key)

      if value.respond_to? :each_pair
        environment_hash.merge!(hash_block.call(key, value, environment_keys))
      else
        environment_key = environment_keys.join('_').upcase

        environment_hash.merge!(value_block.call(key, value, environment_key))
      end
    end

    environment_hash
  end

  def self.convert_value(value)
    return nil if value.nil?

    if value.is_a? String
      case value
      when 'false', 'f', 'no'
        false
      when 'true', 't', 'yes'
        true
      else
        value
      end
    else
      value
    end
  end
end
end
