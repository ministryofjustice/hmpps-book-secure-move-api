class GenericEvent
  class MoveComplete < GenericEvent
    EVENTABLE_TYPES = %w[Move].freeze

    validates :eventable_type, inclusion: { in: EVENTABLE_TYPES }

    def trigger
      eventable.status = Move::MOVE_STATUS_COMPLETED
    end
  end
end
