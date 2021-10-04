class GenericEvent
  class JourneyComplete < GenericEvent
    eventable_types 'Journey'
    validate_occurs_after 'GenericEvent::JourneyStart'

    def trigger(*)
      eventable.complete
    end
  end
end
