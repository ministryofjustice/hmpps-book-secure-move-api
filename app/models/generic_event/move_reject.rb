class GenericEvent
  class MoveReject < GenericEvent
    details_attributes :rejection_reason, :cancellation_reason_comment, :rebook
    eventable_types 'Move'

    validates :rejection_reason, inclusion: { in: Move::REJECTION_REASONS }

    def trigger(dry_run: false)
      eventable.reject(rejection_reason:, cancellation_reason_comment:)
      eventable.rebook if !dry_run && rebook
    end

    def for_feed
      super.tap do |common_feed_attributes|
        common_feed_attributes['details']['rebook'] = rebook || false
      end
    end
  end
end
