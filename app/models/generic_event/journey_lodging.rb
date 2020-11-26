class GenericEvent
  class JourneyLodging < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :to_location_id

    relationship_attributes to_location_id: :locations
    eventable_types 'Journey'

    include LocationValidations

    def for_feed
      super.tap do |common_feed_attributes|
        common_feed_attributes['details'] = to_location.for_feed(prefix: 'to')
      end
    end
  end
end
