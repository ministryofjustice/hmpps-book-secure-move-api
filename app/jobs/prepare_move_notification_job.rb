# frozen_string_literal: true

class PrepareMoveNotificationsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    move = Move.find(args[:topic_id])
    action = args[:action_name]

    move.suppliers.each do |supplier|
      supplier.subscriptions.enabled.each do |subscription|
        notification = subscription.notifications.create!(topic: move,
                                                          event_type: infer_event_type(action))
        NotifyJob.perform_later(notification_id: notification.id)
      end
    end
  end

private

  def infer_event_type(action)
    "#{action}_move"
  end
end
