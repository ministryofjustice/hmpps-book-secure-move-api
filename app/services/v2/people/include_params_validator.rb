# frozen_string_literal: true

module V2
  module People
    class IncludeParamsValidator
      include ActiveModel::Validations

      attr_reader :relationships

      validates_each :relationships, allow_blank: true do |record, attr, value|
        unless (value - ::V2::PersonSerializer::SUPPORTED_RELATIONSHIPS).empty?
          record.errors.add attr, "#{value} are not supported. Valid values are: #{::V2::PersonSerializer::SUPPORTED_RELATIONSHIPS}"
        end
      end

      def initialize(relationships)
        @relationships = relationships
      end
    end
  end
end
