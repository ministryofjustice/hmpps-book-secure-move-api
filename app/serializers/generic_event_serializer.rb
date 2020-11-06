# frozen_string_literal: true

class GenericEventSerializer
  include JSONAPI::Serializer

  set_type :events

  attributes :occurred_at, :recorded_at, :notes, :details

  has_one :eventable, serializer: ->(record, _params) { SerializerVersionChooser.call(record.class) }
  has_one :supplier

  SUPPORTED_RELATIONSHIPS = %w[eventable].freeze

  attribute :event_type do |object|
    object.type.try(:gsub, 'GenericEvent::', '')
  end
end
