class GenericEvent
  class JourneyReject < GenericEvent
    eventable_types 'Journey'
    validate_state_transition :reject

    def trigger(*)
      eventable.reject
    end
  end
end
