# frozen_string_literal: true

class PrepareLodgingNotificationsJob < PrepareBaseNotificationsJob
private

  def find_topic(topic_id)
    Lodging.find(topic_id)
  end

  def associated_move(topic)
    topic.move
  end

  def event_type(action_name, topic, _, _)
    "#{action_name}_#{topic.class.name&.underscore}"
  end
end
