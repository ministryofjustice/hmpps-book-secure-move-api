class Event
  class MoveCancelV2 < Event
    CANCELLATION_REASONS = %w[
    ].freeze

    validates :cancellation_reason, inclusion: { in: Move::CANCELLATION_REASONS }

    def cancellation_reason
      details['cancellation_reason']
    end
  end
end
