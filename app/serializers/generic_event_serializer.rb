# frozen_string_literal: true

class GenericEventSerializer
  include JSONAPI::Serializer

  set_type :events

  attributes :occurred_at, :recorded_at, :notes

  has_one :eventable, serializer: ->(record, _params) { SerializerVersionChooser.call(record.class) }
  has_one :supplier

  SUPPORTED_RELATIONSHIPS = %w[eventable].freeze

  attribute :event_type do |object|
    object.type.try(:gsub, 'GenericEvent::', '')
  end

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
