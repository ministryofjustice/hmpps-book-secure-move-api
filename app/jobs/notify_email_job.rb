# frozen_string_literal: true

class NotifyEmailJob < ApplicationJob
  queue_as :notifications

  def perform(notification_id:)
    notification = Notification.kept.includes(:subscription).find(notification_id)
    return unless notification.subscription.enabled?

    raise 'TODO: coming soon!'
  end
end
