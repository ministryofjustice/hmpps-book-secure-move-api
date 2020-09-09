class GenericEvent
  class JourneyReject < GenericEvent
    include JourneyEventValidations

    def trigger
      eventable.reject
    end

    def self.from_event(event)
      new(event.generic_event_attributes)
    end
  end
end
