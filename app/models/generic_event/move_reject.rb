class GenericEvent
  class MoveReject < GenericEvent
    details_attributes :rejection_reason, :cancellation_reason_comment, :rebook
    eventable_types 'Move'

    validates :rejection_reason, inclusion: { in: Move::REJECTION_REASONS }

    after_create :notify_move_proposer

    def trigger(dry_run: false)
      eventable.reject(rejection_reason:, cancellation_reason_comment:)
      eventable.rebook if !dry_run && rebook
    end

    def for_feed
      super.tap do |common_feed_attributes|
        common_feed_attributes['details']['rebook'] = rebook || false
      end
    end

  private

    def notify_move_proposer
      # If a move is already rejected/cancelled, we don't send the notification
      # The move status changes *after* this generic_event is created
      return if move.cancelled?

      email = move_proposed_by_email
      return unless email

      MoveRejectMailer.notify(email, move, self).deliver_now!
    end

    def move_proposed_by_email
      username =
        move.generic_events
          .where(type: 'GenericEvent::MoveProposed')
          .first&.created_by

      ManageUsersApiClient::UserEmail.get(username) if username
    end
  end
end
