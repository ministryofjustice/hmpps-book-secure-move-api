class GenericEvent
  class JourneyCreate < GenericEvent
    include JourneyEventValidations

    def self.from_event(event)
      new(event.generic_event_attributes)
    end
  end
end
