module ActiveRecord
  module Enum
    class EnumType < Type::Value
      def assert_valid_value(value)
        unless value.blank? || mapping.has_key?(value) || mapping.has_value?(value)
          nil
        end
      end
    end
  end
end
