class GenericEvent
  class MoveComplete < GenericEvent
    eventable_types 'Move'

    def trigger(*)
      eventable.status = Move::MOVE_STATUS_COMPLETED
    end
  end
end
