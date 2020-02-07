module PrepareNotifications
  def prepare_notifications(topic)
    case topic
    when Move
      PrepareMoveNotificationsJob.perform_later(topic_id: topic.id, action_name: action_name)
    when Person
      # Another `Prepare*` job
      puts 'Nothing happens for now other than Rubocop whining'
    end
  end
end
