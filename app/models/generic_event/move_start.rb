class GenericEvent
  class MoveStart < GenericEvent
    DETAILS_ATTRIBUTES = %w[].freeze

    include MoveEventValidations

    def trigger
      eventable.status = Move::MOVE_STATUS_IN_TRANSIT
    end

    def self.from_event(event)
      new(event.generic_event_attributes)
    end
  end
end
