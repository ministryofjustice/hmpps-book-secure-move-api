# frozen_string_literal: true

class Profile::ProfileAttributes::Type < ActiveRecord::Type::Value
  def type
    :jsonb
  end

  def cast(value)
    Profile::ProfileAttributes.new(value)
  end

  def deserialize(value)
    if String == value
      decoded = ::ActiveSupport::JSON.decode(value) rescue nil
      Profile::ProfileAttributes.new(decoded)
    else
      super
    end
  end

  def serialize(value)
    case value
    when Array, Hash
      ::ActiveSupport::JSON.encode(value)
    when Profile::ProfileAttributes
      ::ActiveSupport::JSON.encode(value.as_json)
    else
      super
    end
  end
end
