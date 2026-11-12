class GenericEvent
  class JourneyUncancel < GenericEvent
    eventable_types 'Journey'
    validate_state_transition :uncancel

    def trigger(*)
      eventable.uncancel
    end
  end
end
