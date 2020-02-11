# frozen_string_literal: true

# NB: at the moment this serializer only supports Move topics. In the future we should also support Person topics.
class NotificationSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :event_type
  attribute :created_at, key: :timestamp

  # this is a little ugly but it is the only way (?!) to get the serializer to behave exactly as required
  belongs_to :topic, polymorphic: true, key: 'move', if: :move? do |serializer|
    link :self, serializer.move_url
    object.topic
  end

  def move?
    object.topic.is_a?(Move)
  end

  def move_url
    api_v1_move_url(object.topic.id)
  end
end
