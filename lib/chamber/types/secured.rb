require 'active_support/json'
require 'chamber'

# rubocop:disable Lint/HandleExceptions, Style/EmptyLinesAroundModuleBody
module  Chamber

begin
  require 'active_record/type/value'

  CHAMBER_TYPE_VALUE_SUPERCLASS = ActiveRecord::Type::Value
rescue LoadError
end

begin
  require 'active_model/type/value'

  CHAMBER_TYPE_VALUE_SUPERCLASS = ActiveModel::Type::Value
rescue LoadError
end

module  Types
class   Secured < CHAMBER_TYPE_VALUE_SUPERCLASS
  attr_accessor :decryption_key,
                :encryption_key

  def initialize(options = {})
    self.encryption_key = options.fetch(:encryption_key,
                                        Chamber.configuration.encryption_key)
    self.decryption_key = options.fetch(:decryption_key,
                                        Chamber.configuration.decryption_key)
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
                    decryption_key: decryption_key,
                    encryption_key: encryption_key)
  end
  alias type_cast_from_database deserialize

  def serialize(value)
    fail ArgumentError, 'Any attributes encrypted with Chamber must be a Hash' unless value.is_a?(Hash)

    ::ActiveSupport::JSON.encode(
      Chamber.encrypt(value,
                      decryption_key: decryption_key,
                      encryption_key: encryption_key),
    )
  end
  alias type_cast_for_database serialize

  def changed_in_place?(raw_old_value, new_value)
    deserialize(raw_old_value) == new_value
  end
end
end
end
# rubocop:enable Lint/HandleExceptions, Style/EmptyLinesAroundModuleBody
