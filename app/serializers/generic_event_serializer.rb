# frozen_string_literal: true

class GenericEventSerializer
  include JSONAPI::Serializer

  set_type :events

  attributes :event_type, :occurred_at, :recorded_at, :notes

  # TODO: should this/these be a belongs_to instead?
  # TODO consider using has_one_if_included to lazy load these associations
  has_one :eventable, serializer: ->(record, _params) { SerializerVersionChooser.call(record.class) }
  has_one :supplier

  SUPPORTED_RELATIONSHIPS = %w[eventable].freeze

  attribute :details do |record, _params|
    record.details.deep_dup.tap do |details|
      if record.class.instance_variable_defined?(:@relationship_attributes)
        record.class.relationship_attributes.each do |attribute_key, _attribute_type|
          details.delete(attribute_key)
        end
      end
    end
  end
end
