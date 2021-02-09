# frozen_string_literal: true

class NotificationSerializer
  include JSONAPI::Serializer

  set_type :notifications

  attributes :event_type

  attribute :timestamp, &:created_at

  belongs_to :move, id_method_name: :topic_id, if: proc { |object| object.topic.is_a?(Move) }, links: {
    self: ->(object) { Rails.application.routes.url_helpers.api_move_url(object.topic.id) },
  }

  belongs_to :person_escort_record, id_method_name: :topic_id, if: proc { |object| object.topic.is_a?(PersonEscortRecord) }, links: {
    self: ->(object) { Rails.application.routes.url_helpers.api_person_escort_record_url(object.topic.id) },
  }
end
