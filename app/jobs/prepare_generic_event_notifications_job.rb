# frozen_string_literal: true

class PrepareGenericEventNotificationsJob < PrepareBaseNotificationsJob
private

  def find_topic(topic_id)
    GenericEvent.find(topic_id)
  end

  def associated_move(topic)
    topic.move
  end
end
