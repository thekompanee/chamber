# frozen_string_literal: true

module Chamber
module Refinements
class  Enumerable
  def self.deep_transform_keys(object, &block)
    case object
    when ::Hash
      object.each_with_object({}) do |(key, value), result|
        result[yield(key)] = deep_transform_keys(value, &block)
      end
    when ::Array
      object.map { |e| deep_transform_keys(e, &block) }
    else
      object
    end
  end

  def self.deep_transform_values(key, value, &block)
    case value
    when ::Hash
      value.each_with_object({}) do |(k, v), memo|
        memo[k] = deep_transform_values(k, v, &block)
      end
    when ::Array
      yield(
        key,
        value.map { |v| deep_transform_values(nil, v, &block) }
      )
    else
      yield(key, value)
    end
  end
end
end
end
