class GenericEvent
  class JourneyComplete < GenericEvent
    eventable_types 'Journey'

    def trigger
      eventable.complete
    end

    def self.from_event(event)
      new(event.generic_event_attributes)
    end
  end
end
