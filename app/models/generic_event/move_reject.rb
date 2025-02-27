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
      # The move status changes *after* this generic_event is created
      # So if a move is already cancelled, we don't send a notification
      return if move.cancelled?

      if move_proposed_by_email
        MoveRejectMailer.notify(move_proposed_by_email, move, self).deliver_now!
      end
    end

    def move_proposed_by
      @move_proposed_by ||= move.generic_events
          .where(type: 'GenericEvent::MoveProposed')
          .first&.created_by
    end

    def move_proposed_by_email
      @move_proposed_by_email ||=

        if move_proposed_by =~ URI::MailTo::EMAIL_REGEXP
          # If move_proposed_by is an email address,
          # there is no need to perform a lookup
          move_proposed_by
        elsif move_proposed_by
          ManageUsersApiClient::UserEmail.get(move_proposed_by)
        end
    end
  end
end
