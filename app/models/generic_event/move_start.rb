class GenericEvent
  class MoveStart < GenericEvent
    eventable_types 'Move'

    def trigger(*)
      eventable.status = Move::MOVE_STATUS_IN_TRANSIT
    end
  end
end
