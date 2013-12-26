class Hash
  def symbolize_keys
    dup.symbolize_keys!
  end

  def symbolize_keys!
    keys.each do |key|
      self[(key.to_sym rescue key) || key] = delete(key)
    end

    self
  end

  def deep_merge(other_hash)
    dup.deep_merge!(other_hash)
  end

  def deep_merge!(other_hash)
    other_hash.each_pair do |k,v|
      tv = self[k]
      self[k] = tv.is_a?(Hash) && v.is_a?(Hash) ? tv.deep_merge(v) : v
    end

    self
  end

  def with_indifferent_access
    ActiveSupport::HashWithIndifferentAccess.new_from_hash_copying_default(self)
  end

  alias nested_under_indifferent_access with_indifferent_access
end
