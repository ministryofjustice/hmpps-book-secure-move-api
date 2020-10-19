class GenericEvent
  class MoveCancel < GenericEvent
    DETAILS_ATTRIBUTES = %w[
      cancellation_reason
      cancellation_reason_comment
    ].freeze

    details_attributes :cancellation_reason, :cancellation_reason_comment

    include MoveEventValidations

    validates :cancellation_reason, inclusion: { in: Move::CANCELLATION_REASONS }

    def trigger
      eventable.status = Move::MOVE_STATUS_CANCELLED
      eventable.cancellation_reason = cancellation_reason
      eventable.cancellation_reason_comment = cancellation_reason_comment

      Allocations::RemoveFromNomis.call(eventable)
    end

    def for_feed
      super.tap do |common_feed_attributes|
        # NB: Force cancellation_reason_comment to be present
        common_feed_attributes['details']['cancellation_reason_comment'] = cancellation_reason_comment || ''
      end
    end

    def self.from_event(event)
      new(event.generic_event_attributes
                .merge(
                  details: {
                    cancellation_reason: event.event_params&.dig(:attributes, :cancellation_reason),
                    cancellation_reason_comment: event.event_params&.dig(:attributes, :cancellation_reason_comment),
                  },
                ))
    end
  end
end
