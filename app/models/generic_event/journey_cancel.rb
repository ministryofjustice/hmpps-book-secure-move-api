class GenericEvent
  class JourneyCancel < GenericEvent
    eventable_types 'Journey'

    def trigger
      eventable.cancel
    end

    def self.from_event(event)
      new(event.generic_event_attributes)
    end
  end
end
