# frozen_string_literal: true

# This job is responsible for preparing a set of notify jobs to run
class PreparePersonEscortRecordNotificationsJob < PrepareMoveNotificationsJob
private

  def find_topic(topic_id)
    PersonEscortRecord.find(topic_id)
  end

  def associated_move(topic)
    topic.move
  end
end
