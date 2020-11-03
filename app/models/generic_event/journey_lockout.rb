class GenericEvent
  class JourneyLockout < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :from_location_id

    relationship_attributes from_location_id: :locations
    eventable_types 'Journey'

    include LocationValidations

    def for_feed
      super.tap do |common_feed_attributes|
        common_feed_attributes['details'] = from_location.for_feed(prefix: 'from')
      end
    end

    def self.from_event(event)
      generic_event_attributes = event.generic_event_attributes.merge(
        details: {
          from_location_id: event.event_params&.dig(:relationships, :from_location, :data, :id),
        },
      )

      new(generic_event_attributes)
    end
  end
end
