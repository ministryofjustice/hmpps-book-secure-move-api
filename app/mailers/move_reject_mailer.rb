# frozen_string_literal: true

class MoveRejectMailer < ApplicationMailer
  def notify(email, move, move_reject_event)
    set_template(ENV.fetch('GOVUK_NOTIFY_MOVE_REJECT_TEMPLATE_ID', nil))
    set_reference move.reference

    set_personalisation(
      'move-reference': move.reference,
      'move-id': move.id,
      'from-location': move.from_location.title,
      'to-location': move.to_location.title,
      'rejection-reason': rejection_reason_description(move, move_reject_event.rejection_reason),
      'move-rebooked': move_reject_event.rebook,
      'move-not-rebooked': !move_reject_event.rebook,
    )

    mail(to: email)
  end

private

  def rejection_reason_description(move, rejection_reason)
    case rejection_reason
    when 'no_transport_available'
      'no transport is available for this move'
    when 'no_space_at_receiving_prison'
      "there are no spaces at #{move.to_location.title} on the dates you requested"
    when 'more_info_required'
      'more information is required'
    end
  end
end
