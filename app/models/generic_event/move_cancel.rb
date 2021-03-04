class GenericEvent
  class MoveCancel < GenericEvent
    details_attributes :cancellation_reason, :cancellation_reason_comment
    eventable_types 'Move'

    validates :cancellation_reason, inclusion: { in: Move::CANCELLATION_REASONS }

    def trigger(dry_run: false)
      eventable.status = Move::MOVE_STATUS_CANCELLED
      eventable.cancellation_reason = cancellation_reason
      eventable.cancellation_reason_comment = cancellation_reason_comment

      Allocations::RemoveFromNomis.call(eventable) unless dry_run
    end

    def for_feed
      super.tap do |common_feed_attributes|
        # NB: Force cancellation_reason_comment to be present
        common_feed_attributes['details']['cancellation_reason_comment'] = cancellation_reason_comment || ''
      end
    end
  end
end
