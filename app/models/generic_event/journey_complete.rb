class GenericEvent
  class JourneyComplete < GenericEvent
    DETAILS_ATTRIBUTES = %w[].freeze

    include JourneyEventValidations

    def trigger
      eventable.complete
    end

    def self.from_event(event)
      new(event.generic_event_attributes)
    end
  end
end
