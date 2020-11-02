class GenericEvent
  class MoveAccept < GenericEvent
    eventable_types 'Move'

    def trigger
      eventable.status = Move::MOVE_STATUS_BOOKED
    end

    def self.from_event(event)
      new(event.generic_event_attributes)
    end
  end
end
