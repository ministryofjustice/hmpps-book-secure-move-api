class GenericEvent
  class MoveStart < GenericEvent
    include MoveEventValidations

    def trigger
      eventable.status = Move::MOVE_STATUS_IN_TRANSIT
    end
  end
end
