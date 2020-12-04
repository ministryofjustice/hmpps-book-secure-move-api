class GenericEvent
  class MoveReject < GenericEvent
    details_attributes :rejection_reason, :cancellation_reason_comment, :rebook
    eventable_types 'Move'

    validates :rejection_reason, inclusion: { in: Move::REJECTION_REASONS }

    def trigger
      eventable.status = Move::MOVE_STATUS_CANCELLED
      eventable.rejection_reason = rejection_reason
      eventable.cancellation_reason = Move::CANCELLATION_REASON_REJECTED
      eventable.cancellation_reason_comment = cancellation_reason_comment
      eventable.rebook if rebook
    end

    def for_feed
      super.tap do |common_feed_attributes|
        common_feed_attributes['details']['rebook'] = rebook || false
      end
    end
  end
end
