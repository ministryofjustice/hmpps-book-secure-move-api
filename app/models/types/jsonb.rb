# frozen_string_literal: true

module Types
  class JSONB < ActiveRecord::Type::Value
    def initialize(concrete_class)
      @concrete_class = concrete_class
    end

    def type
      :jsonb
    end

    def cast(value)
      @concrete_class.new(value)
    end

    def deserialize(value)
      if String == value
        decoded = begin
                    ::ActiveSupport::JSON.decode(value)
                  rescue StandardError
                    nil
                  end
        @concrete_class.new(decoded)
      else
        super
      end
    end

    def serialize(value)
      case value
      when Array, Hash
        ::ActiveSupport::JSON.encode(value)
      when @concrete_class
        ::ActiveSupport::JSON.encode(value.as_json)
      else
        super
      end
    end
  end
end
