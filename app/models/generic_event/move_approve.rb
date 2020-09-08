class GenericEvent
  class MoveApprove < GenericEvent
    EVENTABLE_TYPES = %w[Move].freeze

    validates :eventable_type, inclusion: { in: EVENTABLE_TYPES }

    def date
      @date ||= details['date']
    end

    def date=(date)
      details['date'] = date
    end

    def trigger
      eventable.status = Move::MOVE_STATUS_REQUESTED

      eventable.date = date
      Allocations::CreateInNomis.call(eventable) if create_in_nomis?
    end

  private

    def create_in_nomis?
      details.fetch(:create_in_nomis, false)
    end
  end
end
