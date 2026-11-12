class GenericEvent
  class JourneyUncancel < GenericEvent
    eventable_types 'Journey'
    validate_state_transition :uncancel
    validate_event_reversal_after 'GenericEvent::JourneyCancel'

    def trigger(*)
      eventable.uncancel
    end
  end
end
