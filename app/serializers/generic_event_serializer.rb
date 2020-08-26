# frozen_string_literal: true

class GenericEventSerializer < ActiveModel::Serializer
  type 'events'

  attributes :occurred_at, :recorded_at, :notes, :details, :event_type

  has_one :eventable, polymorphic: true

  SUPPORTED_RELATIONSHIPS = %w[].freeze

  def event_type
    object.type.try(:gsub, 'GenericEvent::', '')
  end
end
