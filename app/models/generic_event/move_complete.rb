class GenericEvent
  class MoveComplete < GenericEvent
    DETAILS_ATTRIBUTES = %w[].freeze

    include MoveEventValidations

    def trigger
      eventable.status = Move::MOVE_STATUS_COMPLETED
    end

    def self.from_event(event)
      new(event.generic_event_attributes)
    end
  end
end
