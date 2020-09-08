class GenericEvent
  class JourneyCancel < GenericEvent
    include JourneyEventValidations

    def trigger
      eventable.cancel
    end

    def self.from_event(event)
      new(
        occurred_at: event.client_timestamp,
        recorded_at: event.client_timestamp,
        created_at: event.created_at,
        updated_at: event.updated_at,
        notes: event.notes,
      )
    end
  end
end
