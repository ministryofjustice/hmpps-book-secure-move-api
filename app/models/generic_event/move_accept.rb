class GenericEvent
  class MoveAccept < GenericEvent
    EVENTABLE_TYPES = %w[Move].freeze

    validates :eventable_type, inclusion: { in: EVENTABLE_TYPES }

    def trigger
      eventable.status = Move::MOVE_STATUS_BOOKED
    end
  end
end
