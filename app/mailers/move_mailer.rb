# frozen_string_literal: true

class MoveMailer < BaseMailer
  def notify(notification)
    set_template(ENV.fetch('GOVUK_NOTIFY_MOVE_TEMPLATE_ID', nil))
    set_reference(notification.id)
    notification.topic.tap do |move|
      set_personalisation(
        common_personalisation(notification, move).merge(
          'move-updated-at': move.updated_at.strftime(TIME_FORMAT),
          'move-action': move.status, # this is the same as the move status and will only be "requested", "booked", "in_transit" or "cancelled"
        ),
      )
    end
    mail(to: notification.subscription.email_address)
  end
end
