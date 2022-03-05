# frozen_string_literal: true

require 'chamber/errors/non_conforming_key'

module Chamber
module Refinements
class  Enumerable
  def self.deep_validate_keys(object, &block)
    case object
    when ::Hash
      object.each do |(key, value)|
        fail ::Chamber::Errors::NonConformingKey unless key == yield(key)

        deep_validate_keys(value, &block)
      end
    when ::Array
      object.map { |v| deep_validate_keys(v, &block) }
    else
      object
    end
  end
end
end
end
