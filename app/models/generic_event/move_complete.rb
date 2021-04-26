class GenericEvent
  class MoveComplete < GenericEvent
    eventable_types 'Move'

    def trigger(*)
      eventable.complete
    end
  end
end
