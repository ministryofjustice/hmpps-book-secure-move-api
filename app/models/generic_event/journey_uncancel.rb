class GenericEvent
  class JourneyUncancel < GenericEvent
    eventable_types 'Journey'

    def trigger
      eventable.uncancel
    end

    def self.from_event(event)
      new(event.generic_event_attributes)
    end
  end
end
