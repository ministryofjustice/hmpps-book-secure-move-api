class GenericEvent
  class MoveStart < GenericEvent
    eventable_types 'Move'
    validate_occurs_before 'GenericEvent::MoveComplete', 'GenericEvent::JourneyStart'

    def trigger(*)
      eventable.start
    end
  end
end
