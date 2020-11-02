class GenericEvent
  class JourneyStart < GenericEvent
    eventable_types 'Journey'

    def trigger
      eventable.start
    end

    def self.from_event(event)
      new(event.generic_event_attributes)
    end
  end
end
