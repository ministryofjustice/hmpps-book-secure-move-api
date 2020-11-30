class GenericEvent
  class JourneyLodging < GenericEvent
    LOCATION_ATTRIBUTE_KEY = :to_location_id

    relationship_attributes to_location_id: :locations
    eventable_types 'Journey'

    include LocationValidations
    include LocationFeed
  end
end
