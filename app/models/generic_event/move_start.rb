class GenericEvent
  class MoveStart < GenericEvent
    EVENTABLE_TYPES = %w[Move].freeze

    validates :eventable_type, inclusion: { in: EVENTABLE_TYPES }

    def trigger
      eventable.status = Move::MOVE_STATUS_IN_TRANSIT
    end
  end
end
