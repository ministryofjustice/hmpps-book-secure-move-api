module PrepareNotifications
  def prepare_notifications(topic)
    PrepareNotificationsJob.perform_later(action: action_name, topic: { type: topic.class.to_s, id: topic.id })
  end
end
