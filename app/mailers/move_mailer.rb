# frozen_string_literal: true

class MoveMailer < GovukNotifyRails::Mailer
  TIME_FORMAT = '%d/%m/%Y %T'

  def notify(notification)
    set_template(ENV.fetch('GOVUK_NOTIFY_TEMPLATE_ID', nil))
    set_reference(notification.id)
    notification.topic.tap do |move|
      set_personalisation(
        'move-reference': move.reference,
        'from-location': move.from_location.title,
        # to_location isn't set for prison_recall moves
        'to-location': move.to_location&.title,
        'move-created-at': move.created_at.strftime(TIME_FORMAT),
        'move-updated-at': move.updated_at.strftime(TIME_FORMAT),
        'notification-created-at': Time.current.strftime(TIME_FORMAT),
        'move-action': move.status, # this is the same as the move status and will only be "requested" or "cancelled"
        'move-status': move.status,
        'environment': ENV.fetch('SERVER_FQDN', Rails.env),
        'supplier': notification.subscription.supplier.name,
      )
    end
    mail(to: notification.subscription.email_address)
  end
end
