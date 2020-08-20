class Event
  class MoveCancelV2 < Event
    attr_writer :cancellation_reason

    validates :cancellation_reason, inclusion: { in: Move::CANCELLATION_REASONS }

    def cancellation_reason
      @cancellation_reason ||= details['cancellation_reason']
    end

    def cancellation_reason_comment
      @cancellation_reason_comment ||= details['cancellation_reason_comment']
    end
  end
end
