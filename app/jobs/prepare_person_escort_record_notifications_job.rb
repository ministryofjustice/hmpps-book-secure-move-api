# frozen_string_literal: true

class PreparePersonEscortRecordNotificationsJob < PrepareBaseNotificationsJob
private

  def find_topic(topic_id)
    PersonEscortRecord.find(topic_id)
  end

  def associated_move(topic)
    topic.move
  end
end
