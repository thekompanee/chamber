# frozen_string_literal: true

require 'chamber/errors/non_conforming_key'

module Chamber
module Refinements
class  Enumerable
  def self.deep_validate_keys(object, &block)
    case object
    when ::Hash
      object.each do |(key, value)|
        # fail ::Chamber::Errors::NonConformingKey unless key == yield(key)
        warn "WARNING: Non-String settings keys are deprecated and will be removed in Chamber 3.0. You attempted to access the '#{key}' setting.  See https://github.com/thekompanee/chamber/wiki/Upgrading-To-Chamber-3.0#all-settings-keys-are-now-stored-as-strings for full details. Called from: '#{caller.to_a.first}'" unless key == yield(key) # rubocop:disable Layout/LineLength

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
