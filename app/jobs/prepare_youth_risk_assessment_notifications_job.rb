# frozen_string_literal: true

# This job is responsible for preparing a set of notify jobs to run
class PrepareYouthRiskAssessmentNotificationsJob < PrepareBaseNotificationsJob
private

  def find_topic(topic_id)
    YouthRiskAssessment.find(topic_id)
  end

  def associated_move(topic)
    topic.move
  end
end
