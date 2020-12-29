# frozen_string_literal: true

require 'active_support/json'
require 'chamber'

module  Chamber
begin
  require 'active_record/type/value'

  CHAMBER_TYPE_VALUE_SUPERCLASS = ActiveRecord::Type::Value
rescue LoadError # rubocop:disable Lint/SuppressedException
end

begin
  require 'active_model/type/value'

  CHAMBER_TYPE_VALUE_SUPERCLASS = ActiveModel::Type::Value
rescue LoadError # rubocop:disable Lint/SuppressedException
end

module  Types
class   Secured < CHAMBER_TYPE_VALUE_SUPERCLASS
  attr_accessor :decryption_keys,
                :encryption_keys

  def initialize(decryption_keys: ::Chamber.configuration.decryption_keys,
                 encryption_keys: ::Chamber.configuration.encryption_keys)
    self.decryption_keys = decryption_keys
    self.encryption_keys = encryption_keys

    super()
  end

  def type
    :jsonb
  end

  def cast(value)
    case value
    when Hash
      value
    when String
      ::ActiveSupport::JSON.decode(value)
    when NilClass
      nil
    else
      fail ArgumentError, 'Any attributes encrypted with Chamber must be either a Hash or a valid JSON string'
    end
  end
  alias type_cast_from_user cast

  def deserialize(value)
    value = cast(value)

    return if value.nil?

    Chamber.decrypt(value,
                    decryption_keys: decryption_keys,
                    encryption_keys: encryption_keys)
  end
  alias type_cast_from_database deserialize

  def serialize(value)
    fail ArgumentError, 'Any attributes encrypted with Chamber must be a Hash' unless value.is_a?(Hash)

    ::ActiveSupport::JSON.encode(
      Chamber.encrypt(value,
                      decryption_keys: decryption_keys,
                      encryption_keys: encryption_keys),
    )
  end
  alias type_cast_for_database serialize

  def changed_in_place?(raw_old_value, new_value)
    deserialize(raw_old_value) == new_value
  end
end
end
end
