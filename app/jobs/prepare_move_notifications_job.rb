# frozen_string_literal: true

class PrepareMoveNotificationsJob < ApplicationJob
  queue_as :webhooks

  def perform(topic_id:, action_name:)
    move = Move.find(topic_id)

    move.suppliers.each do |supplier|
      supplier.subscriptions.kept.each do |subscription|
        next unless subscription.enabled?

        notification = subscription.notifications.create!(topic: move,
                                                          event_type: "#{action_name}_move")
        NotifyJob.perform_later(notification_id: notification.id)
      end
    end
  end
end
