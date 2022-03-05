# frozen_string_literal: true

module Chamber
module Refinements
module DeepDup
refine ::Array do
  def deep_dup
    map { |i| i.respond_to?(:deep_dup) ? i.deep_dup : i.dup }
  end
end

refine ::Object do
  def deep_dup
    dup
  end
end

refine ::Hash do
  def deep_dup
    dup.tap do |hash|
      each_pair do |key, value|
        if key.frozen? && key.is_a?(::String)
          hash[key] = value.deep_dup
        else
          hash.delete(key)
          hash[key.deep_dup] = value.deep_dup
        end
      end
    end
  end
end
end
end
end
