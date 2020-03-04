# frozen_string_literal: true

class MoveMailer < GovukNotifyRails::Mailer

  def move_requested(move)
    set_template('8f2e5473-15f2-4db8-a2de-153f26a0524c')

    set_personalisation(
        'move-reference': move.reference,
        'from-location': move.from_location.title,
        'to-location': move.to_location.title,
        'move-created-at': move.created_at,
        'move-updated-at': move.updated_at,
        'move-status': move.status,
        'notification-created-at': Time.now,
        'move-action': 'FOOBAR1',
        'environment': 'FOOBAR2',
        'supplier': 'FOOBAR3'
    )

    mail(to: 'martyn.whitwell@digital.justice.gov.uk')
  end

  def move_cancelled(move)

  end

end
