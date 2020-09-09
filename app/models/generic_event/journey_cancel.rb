class GenericEvent
  class JourneyCancel < GenericEvent
    include JourneyEventValidations

    def trigger
      eventable.cancel
    end

    def self.from_event(event)
      new(event.generic_event_attributes)
    end
  end
end
