class GenericEvent
  class JourneyStart < GenericEvent
    eventable_types 'Journey'
    validate_occurs_before 'GenericEvent::JourneyComplete'
    validate_occurs_after 'GenericEvent::MoveStart'

    def trigger(*)
      eventable.start
    end
  end
end
