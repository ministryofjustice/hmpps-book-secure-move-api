class GenericEvent
  class JourneyStart < GenericEvent
    eventable_types 'Journey'
    validate_occurs_before 'GenericEvent::JourneyComplete'

    def trigger(*)
      eventable.start
    end
  end
end
