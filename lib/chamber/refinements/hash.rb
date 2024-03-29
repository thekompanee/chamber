# frozen_string_literal: true

module Chamber
module Refinements
module Hash
refine ::Hash do
  def deep_merge(other_hash, &block)
    dup.deep_merge!(other_hash, &block)
  end

  def deep_merge!(other_hash, &block)
    merge!(other_hash) do |key, this_val, other_val|
      if this_val.is_a?(::Hash) && other_val.is_a?(::Hash)
        this_val.deep_merge(other_val, &block)
      elsif block
        yield(key, this_val, other_val)
      else
        other_val
      end
    end
  end
end
end
end
end
