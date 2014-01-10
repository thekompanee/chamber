require 'hashie/mash'

module  Chamber
module  Environmentable
  def with_environment(settings, parent_keys, hash_block, value_block)
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
end
end
