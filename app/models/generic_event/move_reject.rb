class GenericEvent
  class MoveReject < GenericEvent
    DETAILS_ATTRIBUTES = %w[
      rejection_reason
      cancellation_reason_comment
      rebook
    ].freeze

    include MoveEventValidations

    validates :rejection_reason, inclusion: { in: Move::REJECTION_REASONS }

    def rejection_reason
      details['rejection_reason']
    end

    def rejection_reason=(reason)
      details['rejection_reason'] = reason
    end

    def cancellation_reason_comment
      details['cancellation_reason_comment']
    end

    def rebook?
      details.fetch('rebook', false)
    end

    def trigger
      eventable.status = Move::MOVE_STATUS_CANCELLED
      eventable.rejection_reason = rejection_reason
      eventable.cancellation_reason = Move::CANCELLATION_REASON_REJECTED
      eventable.cancellation_reason_comment = cancellation_reason_comment
      eventable.rebook if rebook?
    end

    def for_feed
      super.tap do |common_feed_attributes|
        common_feed_attributes['details']['rebook'] = rebook?
      end
    end

    def self.from_event(event)
      new(event.generic_event_attributes
              .merge(
                details: {
                  rejection_reason: event.event_params&.dig(:attributes, :rejection_reason),
                  cancellation_reason_comment: event.event_params&.dig(:attributes, :cancellation_reason_comment),
                  rebook: event.event_params&.dig(:attributes, :rebook) || false,
                },
              ))
    end
  end
end
