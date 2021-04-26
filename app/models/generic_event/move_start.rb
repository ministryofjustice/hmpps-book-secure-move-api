class GenericEvent
  class MoveStart < GenericEvent
    eventable_types 'Move'

    def trigger(*)
      eventable.start
    end
  end
end
