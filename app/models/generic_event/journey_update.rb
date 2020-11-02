class GenericEvent
  class JourneyUpdate < GenericEvent
    eventable_types 'Journey'

    def self.from_event(event)
      new(event.generic_event_attributes.merge(details: event.details))
    end
  end
end
