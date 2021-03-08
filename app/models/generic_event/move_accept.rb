class GenericEvent
  class MoveAccept < GenericEvent
    eventable_types 'Move'

    def trigger(*)
      eventable.status = Move::MOVE_STATUS_BOOKED
    end
  end
end
