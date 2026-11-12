class GenericEvent
  class JourneyUncomplete < GenericEvent
    eventable_types 'Journey'
    validate_state_transition :uncomplete

    def trigger(*)
      eventable.uncomplete
    end
  end
end
