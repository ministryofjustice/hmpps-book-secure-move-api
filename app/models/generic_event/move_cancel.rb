class GenericEvent
  class MoveCancel < GenericEvent
    attr_writer :cancellation_reason

    EVENTABLE_TYPES = %w[Move].freeze

    validates :cancellation_reason, inclusion: { in: Move::CANCELLATION_REASONS }
    validates :eventable_type, inclusion: { in: EVENTABLE_TYPES }

    def cancellation_reason
      @cancellation_reason ||= details['cancellation_reason']
    end

    def cancellation_reason_comment
      @cancellation_reason_comment ||= details['cancellation_reason_comment']
    end

    def trigger
      eventable.status = Move::MOVE_STATUS_CANCELLED
      eventable.cancellation_reason = cancellation_reason
      eventable.cancellation_reason_comment = cancellation_reason_comment

      Allocations::RemoveFromNomis.call(eventable)
    end
  end
end
