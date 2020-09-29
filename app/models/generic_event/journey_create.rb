class GenericEvent
  class JourneyCreate < GenericEvent
    DETAILS_ATTRIBUTES = %w[].freeze

    include JourneyEventValidations

    def self.from_event(event)
      new(event.generic_event_attributes.merge(details: event.details))
    end
  end
end
