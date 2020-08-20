# frozen_string_literal: true

class EventSerializer < ActiveModel::Serializer
  type 'events'

  attributes :client_timestamp, :notes, :details, :event_type

  has_one :eventable, polymorphic: true

  SUPPORTED_RELATIONSHIPS = %w[].freeze
  INCLUDED_FIELDS = {}.freeze

  def event_type
    object.type.try(:gsub, 'Event::', '')
  end
end
