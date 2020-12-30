# frozen_string_literal: true

require 'rspectacular'
require 'chamber/refinements/hash'
require 'chamber/refinements/enumerable'

module Chamber
module Refinements
module Hash
refine ::Hash do
  def deep_strip!
    each do |key, value|
      if value.respond_to?(:strip)
        self[key] = value.strip
      elsif value.respond_to?(:deep_strip!)
        self[key] = value.deep_strip!
      end
    end
  end

  def deep_transform_keys(&block)
    Refinements::Enumerable.deep_transform_keys(self, &block)
  end

  def deep_transform_values(&block)
    Refinements::Enumerable.deep_transform_values(nil, self, &block)
  end

  unless method_defined?(:deep_merge)
    def deep_merge(other, &block)
      dup.deep_merge!(other, &block)
    end
  end

  unless method_defined?(:deep_merge!)
    def deep_merge!(other, &block)
      merge!(other) do |key, value_1, value_2|
        if value_1.is_a?(::Hash) && value_2.is_a?(::Hash)
          value_1.deep_merge(value_2, &block)
        elsif block
          yield(key, value_1, value_2)
        else
          value_2
        end
      end
    end
  end
end
end
end
end
