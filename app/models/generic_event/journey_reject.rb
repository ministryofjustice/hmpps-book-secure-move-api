class GenericEvent
  class JourneyReject < GenericEvent
    eventable_types 'Journey'

    def trigger
      eventable.reject
    end

    def self.from_event(event)
      new(event.generic_event_attributes)
    end
  end
end
