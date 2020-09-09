class GenericEvent
  class MoveComplete < GenericEvent
    include MoveEventValidations

    def trigger
      eventable.status = Move::MOVE_STATUS_COMPLETED
    end
  end
end
