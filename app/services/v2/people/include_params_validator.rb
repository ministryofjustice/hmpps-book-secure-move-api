# frozen_string_literal: true

module V2
  module People
    class IncludeParamsValidator
      include ActiveModel::Validations

      attr_reader :relationships

      validates_each :relationships, allow_blank: true do |record, _attr, values|
        unsupported_values = values - ::V2::PersonSerializer::SUPPORTED_RELATIONSHIPS

        unless unsupported_values.empty?
          record.errors.add 'Bad request', "#{unsupported_values} is not supported. Valid values are: #{::V2::PersonSerializer::SUPPORTED_RELATIONSHIPS}"
        end
      end

      def initialize(relationships)
        @relationships = relationships
      end
    end
  end
end
