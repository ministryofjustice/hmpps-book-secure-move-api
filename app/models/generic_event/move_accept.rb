class GenericEvent
  class MoveAccept < GenericEvent
    eventable_types 'Move'

    def trigger(*)
      eventable.accept
    end
  end
end
