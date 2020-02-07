# frozen_string_literal: true

class NotificationSerializer < ActiveModel::Serializer
  attributes :id, :event_type

  has_one :topic

  INCLUDED_ATTRIBUTES = { topic: %i[id type] }.freeze
end
