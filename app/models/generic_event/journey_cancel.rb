class GenericEvent
  class JourneyCancel < GenericEvent
    eventable_types 'Journey'
    validate_state_transition :cancel

    def trigger(*)
      eventable.cancel
    end
  end
end
