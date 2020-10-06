# frozen_string_literal: true

# NB: at the moment this serializer only supports Move topics. In the future we should also support Person topics.
class NotificationSerializer
  include JSONAPI::Serializer

  set_type :notifications

  attributes :event_type

  attribute :timestamp, &:created_at

  belongs_to :topic, polymorphic: true, key: :move, if: proc { |object| move?(object) }, links: {
    self: ->(object) { Rails.application.routes.url_helpers.api_move_url(object.topic.id) },
  }

  def self.move?(object)
    object.topic.is_a?(Move)
  end
end
