# frozen_string_literal: true

class GenericEventSerializer
  include JSONAPI::Serializer
  include JSONAPI::ConditionalRelationships

  set_type :events

  attributes :event_type, :classification, :occurred_at, :recorded_at, :notes, :created_by

  belongs_to :eventable, serializer: ->(record, _params) { SerializerVersionChooser.call(record.class) }
  belongs_to :supplier

  SUPPORTED_RELATIONSHIPS = %w[eventable].freeze

  attribute :details do |record, _params|
    record.details.deep_dup.tap do |details|
      if record.class.instance_variable_defined?(:@relationship_attributes)
        record.class.relationship_attributes.each_key do |attribute_key|
          details.delete(attribute_key)
        end
      end
    end
  end

  DETAIL_SUMMARY_KEYS = %i[subtype outcome court_outcome court_cell_number stakeholder summary further_details].freeze

  attribute :has_details do |record, _params|
    DETAIL_SUMMARY_KEYS.any? { |key| record.details[key].present? }
  end
end
