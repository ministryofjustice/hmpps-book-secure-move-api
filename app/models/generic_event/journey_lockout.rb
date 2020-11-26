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
  end
end
