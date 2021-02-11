# frozen_string_literal: true

class BaseMailer < GovukNotifyRails::Mailer
  TIME_FORMAT = '%d/%m/%Y %T'
  DATE_FORMAT = '%d/%m/%Y'

  def common_personalisation(notification, move)
    {
      'move-reference': move.reference,
      'from-location': move.from_location.title,
      # NB: to_location isn't set for prison_recall moves, so use N/A instead (GovUK Notify will error if nil is supplied)
      'to-location': move.to_location&.title || 'N/A',
      # NB: date isn't set for proposed moves, so use N/A instead (GovUK Notify will error if nil is supplied)
      'move-date': move.date&.strftime(DATE_FORMAT) || 'N/A',
      'move-date-from': move.date_from&.strftime(DATE_FORMAT) || 'N/A',
      'move-date-to': move.date_to&.strftime(DATE_FORMAT) || 'N/A',
      'move-created-at': move.created_at.strftime(TIME_FORMAT),
      'notification-created-at': Time.zone.now.strftime(TIME_FORMAT),
      'move-status': move.status,
      'environment': ENV.fetch('SERVER_FQDN', Rails.env),
      'supplier': notification.subscription.supplier.name,
      'event-type': notification.event_type,
    }
  end
end
