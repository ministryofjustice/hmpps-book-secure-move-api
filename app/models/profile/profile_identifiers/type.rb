# frozen_string_literal: true

class Profile
  class ProfileIdentifiers
    class Type < ActiveRecord::Type::Value
      def type
        :jsonb
      end

      def cast(value)
        Profile::ProfileIdentifiers.new(value)
      end

      def deserialize(value)
        if String == value
          decoded = begin
                      ::ActiveSupport::JSON.decode(value)
                    rescue StandardError
                      nil
                    end
          Profile::ProfileIdentifiers.new(decoded)
        else
          super
        end
      end

      def serialize(value)
        case value
        when Array, Hash
          ::ActiveSupport::JSON.encode(value)
        when Profile::ProfileIdentifiers
          ::ActiveSupport::JSON.encode(value.as_json)
        else
          super
        end
      end
    end
  end
end
