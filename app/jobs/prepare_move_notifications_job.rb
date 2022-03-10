# frozen_string_literal: true

class PrepareMoveNotificationsJob < PrepareBaseNotificationsJob
private

  def find_topic(topic_id)
    Move.find(topic_id)
  end

  def associated_move(topic)
    topic
  end
end
