class GenericEvent
  class MoveComplete < GenericEvent
    eventable_types 'Move'
    validate_occurs_after 'GenericEvent::MoveStart', 'GenericEvent::JourneyComplete'

    def trigger(*)
      eventable.complete
    end
  end
end
