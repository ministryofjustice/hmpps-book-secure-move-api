class GenericEvent
  class JourneyUncancel < GenericEvent
    include JourneyEventValidations

    def trigger
      eventable.uncancel
    end

    def self.from_event(event)
      new(event.generic_event_attributes)
    end
  end
end
