# frozen_string_literal: true

require 'rspectacular'
require 'chamber/refinements/enumerable'

module Chamber
module Refinements
module Array
refine ::Array do
  def deep_transform_keys(&block)
    Refinements::Enumerable.deep_transform_keys(self, &block)
  end

  def deep_transform_values(&block)
    Refinements::Enumerable.deep_transform_values(nil, self, &block)
  end
end
end
end
end
