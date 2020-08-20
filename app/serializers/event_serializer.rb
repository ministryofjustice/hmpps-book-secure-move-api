# frozen_string_literal: true

class EventSerializer < ActiveModel::Serializer
  attributes :client_timestamp, :notes, :details

  has_one :eventable, polymorphic: true

  SUPPORTED_RELATIONSHIPS = %w[].freeze
  INCLUDED_FIELDS = {}.freeze

  def event_type
    type
  end
end
