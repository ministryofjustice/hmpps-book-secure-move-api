class GenericEvent
  class JourneyUncomplete < GenericEvent
    eventable_types 'Journey'
    validate_state_transition :uncomplete
    validate_event_reversal_after 'GenericEvent::JourneyComplete'

    def trigger(*)
      eventable.uncomplete
    end
  end
end
