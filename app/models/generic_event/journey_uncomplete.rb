class GenericEvent
  class JourneyUncomplete < GenericEvent
    include JourneyEventValidations

    def trigger
      eventable.uncomplete
    end

    def self.from_event(event)
      new(event.generic_event_attributes)
    end
  end
end
