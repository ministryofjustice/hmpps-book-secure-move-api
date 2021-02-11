# frozen_string_literal: true

class PersonEscortRecordMailer < BaseMailer
  def notify(notification)
    set_template(ENV.fetch('GOVUK_NOTIFY_PER_TEMPLATE_ID', nil))
    set_reference(notification.id)
    notification.topic.tap do |per|
      set_personalisation(
        common_personalisation(notification, per.move).merge(
          'per-amended-at': per.amended_at.strftime(TIME_FORMAT),
        ),
      )
    end
    mail(to: notification.subscription.email_address)
  end
end
