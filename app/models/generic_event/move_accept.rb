class GenericEvent
  class MoveAccept < GenericEvent
    eventable_types 'Move'
    validate_state_transition :accept

    def trigger(*)
      eventable.accept
    end
  end
end
