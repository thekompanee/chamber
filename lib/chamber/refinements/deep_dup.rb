# frozen_string_literal: true

module Chamber
module Refinements
module DeepDup
refine ::Array do
  unless method_defined?(:deep_dup)
    def deep_dup
      map do |i|
        if i.respond_to?(:deep_dup)
          i.deep_dup
        else
          begin
            i.dup
          rescue ::TypeError
            # Hack for < Ruby 2.4 since FalseClass, TrueClass, Fixnum, etc can't be
            # dupped
            i
          end
        end
      end
    end
  end
end

refine ::Object do
  unless method_defined?(:deep_dup)
    def deep_dup
      begin
        dup
      rescue ::TypeError
        # Hack for < Ruby 2.4 since FalseClass, TrueClass, Fixnum, etc can't be
        # dupped
        self
      end
    end
  end
end

refine ::Hash do
  unless method_defined?(:deep_dup)
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
end
